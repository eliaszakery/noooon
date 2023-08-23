#!/bin/bash

CYAN="\e[1;36m"
GREEN="\e[1;32m"
RED="\e[1;31m"
YELLOW="\e[1;33m"
RESET="\e[0m"

database="/root/users.db"
echo $$ > /tmp/pids
fun_ssh () {
    ssh_config_file="/etc/ssh/sshd_config"
    port_ssh=$(grep -E "^Port\s+[0-9]+" $ssh_config_file | awk '{print $2}')
    log=/var/log/auth.log
    loginsukses='Accepted publickey'
    clear
    pids=$(ps ax | grep "sshd:.*@.*port $port_ssh" | awk -F" " '{print $1}')
    for pid in $pids
    do
        pidlogs=$(grep $pid $log | grep "$loginsukses" | awk -F" " '{print $3}')
        i=0
        for pidend in $pidlogs
        do
            let i=i+1
        done
        if [ $pidend ];then
            login=$(grep $pid $log | grep "$pidend" | grep "$loginsukses")
            PID=$pid
            user=$(echo $login | awk -F" " '{print $9}')
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
if [ ! -f "$database" ]
then
    echo -e "${RED}/root/users.db file not found${NC}"
    exit 1
fi
while true
do
    clear
    echo ""
    echo -e "${CYAN}    OPENSSH LIMITER MONITORING      ${NC}"
    echo ""
    echo -e "${CYAN} Username           Limit-connection ${NC}"
    echo ""
    while read usline
    do
        user="$(echo $usline | cut -d' ' -f1)"
        s2ssh="$(echo $usline | cut -d' ' -f2)"
        s3ssh="$(fun_ssh | grep "$user" | wc -l)"
        if [ -z "$user" ] ; then
            echo "" > /dev/null
        else
            fun_ssh | grep "$user" | awk '{print $2}' |cut -d' ' -f2 > /tmp/userpid
            sed -n '2 p' /tmp/userpid > /tmp/tmp2
            rm /tmp/userpid
            tput setaf 3 ; tput bold ; printf '  %-35s%s\n' "$(tput setaf 3)$user$(tput sgr0)" "$(tput setaf 2)$s3ssh/$s2ssh$(tput sgr0)"; tput sgr0
            if [ "$s3ssh" -gt "$s2ssh" ]; then
                echo -e "${RED} User disconnected for exceeding the limit! ${NC}"
                while read line
                do
                   tmp="$(echo $line | cut -d' ' -f1)"
                   kill $tmp
                done < /tmp/tmp2
                rm /tmp/tmp2
            fi
        fi
     done < "$database"
     sleep 4
done
