#! /bin/bash
set -e # explanation here: https://stackoverflow.com/questions/19622198/what-does-set-e-mean-in-a-bash-script 
server="$(grep -e "Hostname" "$(find /mnt/c/Users/jpg/Documents/secCRT/Sessions/ -type f | fzf)")"
address=$(echo $server | sed s/.*=//) # grab only the ip address from the matched grep expression from line above
address=${address//$'\r'} # remove a hidden <carriage return> from the variable, it's there because windows is dumb and terminates file lines with these
ssh "jpg@${address}" # profit
#sshpass -p "Blaster87" ssh "jpg@${address}"
#echo $address
