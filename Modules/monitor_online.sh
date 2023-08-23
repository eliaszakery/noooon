#!/bin/bash

CYAN="\e[1;36m"
GREEN="\e[1;32m"
RED="\e[1;31m"
YELLOW="\e[1;33m"
WHITE="\e[1;0m"
RESET="\e[0m"

# Function to wait for user input before exiting
press_enter_to_continue() {
    echo -e "       ${YELLOW} Press.....${NC} ${RED} ENTER ${NC} ${YELLOW}.....to continue${NC}"
    read -s -r -p ""
    sleep 0.5
    return
}

clear

database="/root/users.db"

# Function to check active Dropbear connections
fun_drop () {
    port_dropbear=$(ps aux | grep dropbear | awk NR==1 | awk '{print $17;}')
    log=/var/log/auth.log
    loginsukses='Password auth succeeded'
    pids=$(ps ax | grep dropbear | grep " $port_dropbear" | awk -F" " '{print $1}')

    for pid in $pids; do
        pidlogs=$(grep $pid $log | grep "$loginsukses" | awk -F" " '{print $3}')
        i=0

        for pidend in $pidlogs; do
            let i=i+1
        done

        if [ $pidend ]; then
            login=$(grep $pid $log | grep "$pidend" | grep "$loginsukses")
            PID=$pid
            user=$(echo $login | awk -F" " '{print $10}' | sed -r "s/'/ /g")
            waktu=$(echo $login | awk -F" " '{print $2"-"$1,$3}')

            while [ ${#waktu} -lt 13 ]; do
                waktu=$waktu" "
            done

            while [ ${#user} -lt 16 ]; do
                user=$user" "
            done

            while [ ${#PID} -lt 8 ]; do
                PID=$PID" "
            done

            echo "$user $PID $waktu"
        fi
    done
}

# Print header
echo ""
echo -e "${CYAN} USERNAME    LIMIT      ONLINE-TIME   ONLINE-STATUS  ${NC}"
tput sgr0
tput bold; tput setaf 6
echo "───────────────────────────────────────────────────"
tput sgr0

# Loop through each user in the database
while read usline; do
    user="$(echo $usline | cut -d' ' -f1)"
    s2ssh="$(echo $usline | cut -d' ' -f2)"

    # Count active SSH connections
    if [ "$(cat /etc/passwd | grep -w $user | wc -l)" = "1" ]; then
        sqd="$(ps -u $user | grep sshd | wc -l)"
    else
        sqd=0
    fi

    # Count active Dropbear connections
    if netstat -nltp | grep 'dropbear' > /dev/null; then
        drop="$(fun_drop | grep "$user" | wc -l)"
    else
        drop=0
    fi

    # Calculate total connections
    cnx=$(($sqd + $drop))

    # Calculate the formatted time of the longest active connection
    if [[ $cnx -gt 0 ]]; then
        tst="$(ps -o etime $(ps -u $user | grep sshd | awk 'NR==1 {print $1}') | awk 'NR==2 {print $1}')"
        tst1=$(echo "$tst" | wc -c)

        if [[ "$tst1" == "9" ]]; then
            timerr="$(ps -o etime $(ps -u $user | grep sshd | awk 'NR==1 {print $1}') | awk 'NR==2 {print $1}')"
        else
            timerr="$(echo "00:$tst")"
        fi
    else
        timerr="00:00:00"
    fi

   # Set user's online status
if [[ $cnx -eq 0 ]]; then
    status="   ${NC} $(tput setaf 1)✗$(tput sgr0)"
else
    status="   ${NC} $(tput setaf 2)✔$(tput sgr0)"
fi

# Print user's status and connection details for the first line
tput bold; tput setaf 7
printf '%-14s%-12s%-11s%s\n' " $user" "$cnx/$s2ssh" "$timerr" "$status"
tput sgr0
tput bold; tput setaf 3
echo "───────────────────────────────────────────────────"
tput sgr0

done < "$database"

echo -e "${CYAN} ONLINE USERS${NC} =>  $(tput setaf 2)✔$(tput sgr0)  ${CYAN}OFFLINE USERS${NC} =>  $(tput setaf 1)✗$(tput sgr0)"

press_enter_to_continue
