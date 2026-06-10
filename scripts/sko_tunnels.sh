#!/usr/bin/env bash
#
# sko_tunnels.sh
#
# Usage: ./sko_tunnels.sh <store_number>
#
# Example: ./sko_tunnels.sh 298

set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <3-digit store number>" >&2
  exit 1
fi

STORE="$1"

# Validate: exactly 3 digits 000–999
if ! [[ "$STORE" =~ ^[0-9]{3}$ ]]; then
  echo "Error: store number must be exactly 3 digits (e.g., 001, 298, 450)." >&2
  exit 1
fi

# =========================
# CONFIG - EDIT THESE
# =========================

# Your FortiManager JSON-RPC endpoint
FMG_URL="https://net.shopko.com/jsonrpc" # <-- change this

# ADOM that your branches live in ("root", "branches", etc.)
ADOM="Stores" # <-- change if needed

# VDOM name on the FortiGates (common case is "root")
VDOM="root"

# API key from your FortiManager REST API admin ("automation")
FMG_API_KEY="5m18h4tajzuhu8toukgn7eg7b4cmj9bs" # <-- paste your key

if [[ -z "$FMG_API_KEY" ]]; then
  echo "FMG_API_KEY is empty. Edit the script and set it." >&2
  exit 1
fi

# Ensure VDOM has some value even under `set -u`
: "${VDOM:=root}"

# =========================
# Helpeg: FMG JSON-gPC call
# =========================

fmg_call() {
  local json="$1"
  curl -sk \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $FMG_API_KEY" \
    -d "$json" \
    "$FMG_URL"
}

echo "== FortiManager: querying devices for store '$STORE' (ADOM '$ADOM') =="

# 1) Get device list from ADOM
DEVICE_LIST_PAYLOAD=$(
  cat <<EOF
{
  "id": 1,
  "method": "get",
  "params": [
    {
      "url": "/dvmdb/adom/$ADOM/device"
    }
  ]
}
EOF
)

DEVICE_LIST_RESP=$(fmg_call "$DEVICE_LIST_PAYLOAD")

DEVICE_LIST_RC=$(echo "$DEVICE_LIST_RESP" | jq -r '.result[0].status.code // -1')
DEVICE_LIST_MSG=$(echo "$DEVICE_LIST_RESP" | jq -r '.result[0].status.message // ""')

if [[ "$DEVICE_LIST_RC" != "0" ]]; then
  echo "Error fetching device list from ADOM '$ADOM' (code=$DEVICE_LIST_RC, msg=\"$DEVICE_LIST_MSG\")" >&2
  echo "$DEVICE_LIST_RESP" | jq >&2
  exit 1
fi

# 2) Filter devices whose name contains the store string.
DEVICE_NAMES=$(echo "$DEVICE_LIST_RESP" |
  jq -r --arg STORE "$STORE" '.result[0].data // [] | .[] | select(.name | test($STORE)) | .name')

if [[ -z "$DEVICE_NAMES" ]]; then
  echo "No devices found matching store '$STORE' in ADOM '$ADOM'." >&2
  exit 1
fi

echo "Devices found:"
echo "$DEVICE_NAMES"
echo

# Arrays of IPs to ping + labels (device/interface)
declare -a PING_IPS=()
declare -a PING_LABELS=()

# 3) For each device, query global/system/interface with a vdom filter
while read -r DEVNAME; do
  [[ -z "$DEVNAME" ]] && continue

  echo "== Gathering target interface IPs on device '$DEVNAME' (vdom '$VDOM') =="

  # ---- 3a) Config view via /pm/config/... (ADVPN/ADVPN2/DATA_VLAN + WANs) ----
  IFACE_PAYLOAD=$(
    cat <<EOF
{
  "id": 2,
  "method": "get",
  "params": [
    {
      "url": "/pm/config/device/$DEVNAME/global/system/interface",
      "fields": ["name", "type", "ip", "vdom"],
      "filter": ["vdom", "==", "$VDOM"]
    }
  ]
}
EOF
  )

  IFACE_RESP=$(fmg_call "$IFACE_PAYLOAD")

  IFACE_RC=$(echo "$IFACE_RESP" | jq -r '.result[0].status.code // -1')
  IFACE_MSG=$(echo "$IFACE_RESP" | jq -r '.result[0].status.message // ""')

  if [[ "$IFACE_RC" != "0" ]]; then
    echo "  Error fetching interfaces for $DEVNAME (code=$IFACE_RC, msg=\"$IFACE_MSG\")" >&2
    echo "  Raw response:"
    echo "$IFACE_RESP" | jq >&2
    echo
    continue
  fi

  # 3a-1) Targets we can fully resolve from config (non-DHCP IPs):
  #   - ADVPN, ADVPN2, wan1, wan2, DATA_VLAN, but only if ip != 0.0.0.0
  CONFIG_TARGETS=$(echo "$IFACE_RESP" |
    jq -r '
        .result[0].data // [] |
        .[] |
        select(
          .name == "ADVPN" or
          .name == "ADVPN2" or
          .name == "wan1" or
          .name == "wan2" or
          .name == "DATA_VLAN"
        ) |
        {name, ip: .ip[0]} |
        select(.ip != "0.0.0.0") |
        "\(.name) \(.ip)"
      ' |
    sed '/^$/d')

  # 3a-2) WAN interfaces that *need* runtime lookup (DHCP → 0.0.0.0 in config)
  WANS_NEED_RUNTIME=$(echo "$IFACE_RESP" |
    jq -r '
        .result[0].data // [] |
        .[] |
        select(.name == "wan1" or .name == "wan2") |
        {name, ip: .ip[0]} |
        select(.ip == "0.0.0.0") |
        .name
      ' |
    sed '/^$/d')

  if [[ -n "$CONFIG_TARGETS" ]]; then
    echo "  Relevant interfaces from FMG config on $DEVNAME (skipping 0.0.0.0):"
    while read -r ifname ip; do
      [[ -z "${ifname:-}" || -z "${ip:-}" ]] && continue
      echo "    $ifname = $ip"
      PING_IPS+=("$ip")
      PING_LABELS+=("$DEVNAME/$ifname")
    done <<<"$CONFIG_TARGETS"
    echo
  else
    echo "  No non-DHCP ADVPN/ADVPN2/wan1/wan2/DATA_VLAN IPs in config on $DEVNAME."
    echo
  fi

  # ---- 3b) Runtime view via FMG proxy (sys/proxy/json) for wan1/wan2 DHCP ----
  if [[ -z "$WANS_NEED_RUNTIME" ]]; then
    echo "  No DHCP WAN interfaces (wan1/wan2 with 0.0.0.0) on $DEVNAME that need runtime lookup."
    echo
    continue
  fi

  echo "  WAN interfaces needing runtime IP lookup on $DEVNAME:"
  echo "$WANS_NEED_RUNTIME" | sed 's/^/    /'
  echo

  RUNTIME_PAYLOAD=$(
    cat <<EOF
{
  "id": 99,
  "method": "exec",
  "params": [
    {
      "url": "sys/proxy/json",
      "data": {
        "action": "get",
        "resource": "/api/v2/monitor/system/interface/?vdom=$VDOM",
        "target": [
          "adom/$ADOM/device/$DEVNAME"
        ]
      }
    }
  ]
}
EOF
  )

  RUNTIME_RESP=$(fmg_call "$RUNTIME_PAYLOAD")

  # NOTE: sys/proxy/json wraps the FortiGate REST response. We don't know the
  # exact nesting a priori, so we:
  #   - walk all objects
  #   - find those that have a "results" key (typical FOS monitor output)
  #   - pull wan1/wan2 from there.
  RUNTIME_WAN_TARGETS=$(echo "$RUNTIME_RESP" |
    jq -r '
        .. | objects | select(has("results")) |
        .results[]? |
        select(.name == "wan1" or .name == "wan2") |
        "\(.name) \(.ip)"
      ' |
    sed '/^$/d')

  if [[ -z "$RUNTIME_WAN_TARGETS" ]]; then
    echo "  Could not find runtime WAN info for $DEVNAME in proxy response."
    echo "  (You can debug by printing RUNTIME_RESP with jq in the script.)"
    echo
    continue
  fi

  echo "  Runtime WAN IPs on $DEVNAME (via sys/proxy/json):"
  while read -r ifname ip; do
    [[ -z "${ifname:-}" || -z "${ip:-}" ]] && continue
    # Skip any bogus/empty IPs just in case
    if [[ "$ip" == "0.0.0.0" ]]; then
      echo "    $ifname = $ip (still 0.0.0.0 – ignoring)"
      continue
    fi
    echo "    $ifname = $ip"
    PING_IPS+=("$ip")
    PING_LABELS+=("$DEVNAME/$ifname (runtime)")
  done <<<"$RUNTIME_WAN_TARGETS"
  echo

done <<<"$DEVICE_NAMES"

if [[ ${#PING_IPS[@]} -eq 0 ]]; then
  echo "No interface IPs found to ping for store '$STORE'."
  exit 0
fi

echo "== Pinging interface IPs for store '$STORE' =="
echo

declare -a UP_ITEMS=()
declare -a DOWN_ITEMS=()

for i in "${!PING_IPS[@]}"; do
  ip="${PING_IPS[$i]}"
  label="${PING_LABELS[$i]}"

  echo "Pinging $label ($ip) ..."
  if ping -c 3 -W 1 "$ip" >/dev/null 2>&1; then
    echo "  $ip is reachable"
    UP_ITEMS+=("$label $ip")
  else
    echo "  $ip is NOT reachable"
    DOWN_ITEMS+=("$label $ip")
  fi
  echo
done

echo "== Summary for store '$STORE' =="

echo
echo "Reachable:"
if [[ ${#UP_ITEMS[@]} -eq 0 ]]; then
  echo "  None"
else
  for item in "${UP_ITEMS[@]}"; do
    echo "  $item"
  done
fi

echo
echo "Unreachable:"
if [[ ${#DOWN_ITEMS[@]} -eq 0 ]]; then
  echo "  None"
else
  for item in "${DOWN_ITEMS[@]}"; do
    echo "  $item"
  done
fi

echo "Done."
