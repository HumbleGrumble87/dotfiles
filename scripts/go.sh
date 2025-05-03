#!/usr/bin/bash

# this script should be aliased in bash, so that you can run it from anywhere with a common command.
# i aliased mine to "go" in my bashrc file
# alias go=~/$HOME/scripts/go.sh

# this scripts requires 'plocate' and 'fzf' to be installed,
# sudo apt install plocate fzf

# ------------------------------------------------------------------------------

# this script requires you to run a sql query with a sql client of your choice (i run popSQL)
# and save the output as a csv, mine is in a folder called 'sharedSessions/'
# i name my sql queries sharedSessions-DATE.csv, update my plocateDB, grep for my sessions, sort them, take the most recent file (remember, they're DATED)
# and save it as a variable 'most_recent_csv'
# the query in question is commented out at the end of the script below.
#most_recent_csv="$(plocate 2025 | grep "sharedSessions/sharedSessions.*csv$" | sort -r | head -1)"
most_recent_csv="$(find /home/jimmy/sharedSessions -type f -iname '*sessions*' | grep "sharedSessions/sharedSessions.*csv$" | sort -r | head -1)"
# feel free to "echo $most_recent_csv" to t-shoot the script if needed

# here i set a variable called host that utilizes fzf fuzzy finder to find device record based on device name/description
host=$(cat "$most_recent_csv" | fzf)
# echo $host

# here i pull pull the ip address from the record above
address=$(echo $host | grep -ohE "^[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}")
# echo $address

# i automatically call ct (aka chromaterm) in order to synax highlight my ssh session
# ct ssh "jpg@${address}"

# profit

ct sshpass -p "Suzuki94" ssh "jpg@${address}"
#echo $address
