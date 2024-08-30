#!/usr/bin/bash
set -e # explanation here: https://stackoverflow.com/questions/19622198/what-does-set-e-mean-in-a-bash-script

most_recent_csv="$(plocate 2024 | grep "Inc/secCRT/ImportFromTextFile/sharedSessions.*csv$" | sort -r | head -1)"
#echo $most_recent_csv

host=$(cat "$most_recent_csv" | fzf)
echo $host

address=$(echo $host | grep -ohE "^[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}")
echo $address

#ssh "jpg@${address}" # profit

sshpass -p "Suzuki_98" ssh "jpg@${address}"
#echo $address
