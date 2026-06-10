#!/usr/bin/env bash

LOG_DIR="$HOME/tmux-logs"
COMPRESSED_DIR="$LOG_DIR/compressed"
LIMIT_KB=5242880    # 5 GiB
STATE_FILE="$HOME/.tmux-log-alert"

mkdir -p "$LOG_DIR" "$COMPRESSED_DIR"

# Compress logs older than 7 days, excluding already-compressed logs
find "$LOG_DIR" \
  -maxdepth 1 \
  -type f \
  -name "*.log" \
  -mtime +7 \
  -print0 |
while IFS= read -r -d '' LOG_FILE; do
    YEAR=$(date -r "$LOG_FILE" +%Y)
    MONTH=$(date -r "$LOG_FILE" +%m)
    DEST_DIR="$COMPRESSED_DIR/$YEAR/$MONTH"

    mkdir -p "$DEST_DIR"

    gzip -c "$LOG_FILE" > "$DEST_DIR/$(basename "$LOG_FILE").gz" && rm -f "$LOG_FILE"
done

# Alert if total tmux-logs directory exceeds limit
SIZE_KB=$(du -sk "$LOG_DIR" | awk '{print $1}')

if [ "$SIZE_KB" -gt "$LIMIT_KB" ]; then
    if [ ! -f "$STATE_FILE" ]; then
        SIZE_HUMAN=$(du -sh "$LOG_DIR" | awk '{print $1}')
        notify-send "tmux logs are large" "$LOG_DIR is now $SIZE_HUMAN"
        touch "$STATE_FILE"
    fi
else
    rm -f "$STATE_FILE"
fi
