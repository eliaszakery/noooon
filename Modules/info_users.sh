#!/bin/bash
clear
echo -e "\E[44;1;37mUser        Password      Limit       Validity \E[0m"
echo ""

# Loop through each user
for users in $(awk -F : '$3 > 900 { print $1 }' /etc/passwd | sort | grep -v "nobody" | grep -vi polkitd | grep -vi system-); do
    # Get user's limit from users.db
    if [[ $(grep -cw $users $HOME/users.db) == "1" ]]; then
        lim=$(grep -w $users $HOME/users.db | cut -d' ' -f2)
    else
        lim="1"
    fi

    # Get user's password from password file
    if [[ -e "/etc/OPIranPanel/password/$users" ]]; then
        password=$(cat /etc/OPIranPanel/password/$users)
    else
        password="Null"
    fi

    # Get user's validity date
    dateuser=$(chage -l $users | grep -i co | awk -F : '{print $2}')
    if [ $dateuser = never ] 2> /dev/null; then
        date="\033[1;33mNone\033[0m"
    else
        datebr="$(date -d "$dateuser" +"%Y%m%d")"
        today="$(date -d today +"%Y%m%d")"
        if [ $today -ge $datebr ]; then
            date="\033[1;31mNull\033[0m"
        else
            dat="$(date -d"$dateuser" '+%Y-%m-%d')"
            date=$(echo -e "$((($(date -ud $dat +%s)-$(date -ud $(date +%Y-%m-%d) +%s))/86400)) \033[1;37mdays\033[0m")
        fi
    fi

    # Format and display user details
    username=$(printf ' %-15s' "$users")
    password=$(printf '%-13s' "$password")
    Limit=$(printf '%-10s' "$lim")
    date=$(printf '%-1s' "$date")
    echo -e "\033[1;33m$username \033[1;37m$password \033[1;37m$Limit \033[1;32m$date\033[0m"
    echo -e "\033[0;34m────────────────────────────────────────────────────────\033[0m"
done

# Display summary information
_tuser=$(awk -F: '$3>=1000 {print $1}' /etc/passwd | grep -v nobody | wc -l)
_ons=$(ps -x | grep sshd | grep -v root | grep priv | wc -l)
[[ "$(cat /etc/OPIranPanel/Exp)" != "" ]] && _expuser=$(cat /etc/OPIranPanel/Exp) || _expuser="0"
[[ -e /etc/default/dropbear ]] && _drp=$(ps aux | grep dropbear | grep -v grep | wc -l) _ondrp=$(($_drp - 1)) || _ondrp="0"
_onli=$(($_ons + $_ondrp))
echo -e "\033[1;33m \033[1;36mTOTAL USERS\033[1;37m $_tuser \033[1;33m \033[1;32mONLINE\033[1;37m: $_onli \033[1;33m \033[1;31mEXPIRED\033[1;37m: $_expuser \033[1;33m\033[0m"
