#!/bin/bash

# Color variables for better readability
RED=$(tput setaf 1)
YELLOW=$(tput setaf 3)
CYAN=$(tput setaf 6)
GREEN=$(tput setaf 2)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
WHITE=$(tput setaf 7)
BOLD=$(tput bold)
RESET=$(tput sgr0)

# Main script
database="/root/users.db"

clear
tput setaf 7 ; tput setab 4 ; tput bold ; printf '%32s%s%-13s\n' "ㅤㅤ🚮ㅤRemove SSH Userㅤ🚮ㅤㅤ" ; tput sgr0
echo ""
echo -e "${RED}[${CYAN}1${RED}]${YELLOW} REMOVE A USER"
echo -e "${RED}[${CYAN}2${RED}]${YELLOW} REMOVE ALL USERS"
echo -e "${RED}[${CYAN}3${RED}]${YELLOW} COME BACK"
echo ""
read -p "$(echo -e "${GREEN} WHAT DO YOU WANT TO DO${RED}?${WHITE} : ")" -e -i 1 resp

# Remove a single user
if [[ "$resp" = "1" ]]; then
    clear
    tput setaf 7 ; tput setab 4 ; tput bold ; printf '%32s%s%-13s\n' "ㅤㅤ🚮ㅤRemove SSH Userㅤ🚮ㅤㅤ" ; tput sgr0
    echo ""
    echo -e "${YELLOW} USERS LIST: ${RESET}"
    echo ""

    # Display the list of users
    _userT=$(awk -F: '$3>=1000 {print $1}' /etc/passwd | grep -v nobody)
    i=0
    unset _userPass
    while read -r _user; do
        i=$(expr $i + 1)
        _oP=$i
        [[ $i == [1-9] ]] && i=0$i && _oP+=" 0$i"
        echo -e "${RED}[${CYAN}$i${RED}] ${WHITE}- ${GREEN}$_user${RESET}"
        _userPass+="\n${_oP}:${_user}"
    done <<< "${_userT}"

    echo ""
    num_user=$(awk -F: '$3>=1000 {print $1}' /etc/passwd | grep -v nobody | wc -l)
    echo -ne "${GREEN} Enter or select a user ${YELLOW}[${CYAN}1${RED}-${CYAN}$num_user${YELLOW}]${WHITE}: " ; read -r option
    user=$(echo -e "${_userPass}" | grep -E "\b$option\b" | cut -d: -f2)

    if [[ -z $option ]] || [[ -z $user ]]; then
        tput setaf 7 ; tput setab 1 ; tput bold ; echo "" ; echo " User is empty or invalid! " ; echo "" ; tput sgr0
        exit 1
    else
        if cat /etc/passwd | grep -w "$user" > /dev/null; then
            echo ""
            pkill -f "$user" > /dev/null 2>&1
            deluser --force "$user" > /dev/null 2>&1
            echo -e "\E[41;1;37m User $user successfully removed! \E[0m"
            grep -v "^$user[[:space:]]" /root/users.db > /tmp/ph ; cat /tmp/ph > /root/users.db
            rm "/etc/OPIranPanel/password/$user" > /dev/null 2>&1

            if [[ -e /etc/openvpn/server.conf ]]; then
                remove_ovp "$user"
            fi
            exit 1
        elif [[ "$(cat "$database"| grep -w "$user"| wc -l)" -ne "0" ]]; then
            ps x | grep "$user" | grep -v grep | grep -v pt > /tmp/rem
            if [[ $(grep -c "$user" /tmp/rem) -eq 0 ]]; then
                deluser --force "$user" > /dev/null 2>&1
                echo ""
                echo -e "\E[41;1;37m User $user successfully removed! \E[0m"
                grep -v "^$user[[:space:]]" /root/users.db > /tmp/ph ; cat /tmp/ph > /root/users.db
                rm "/etc/OPIranPanel/password/$user" > /dev/null 2>&1

                if [[ -e /etc/openvpn/server.conf ]]; then
                    remove_ovp "$user"
                fi
                exit 1
            else
                echo ""
                tput setaf 7 ; tput setab 4 ; tput bold ; echo "" ; echo " User logged in. Disconnecting..." ; tput sgr0
                pkill -f "$user" > /dev/null 2>&1
                deluser --force "$user" > /dev/null 2>&1
                echo -e "\E[41;1;37m User $user successfully removed! \E[0m"
                grep -v "^$user[[:space:]]" /root/users.db > /tmp/ph ; cat /tmp/ph > /root/users.db
                rm "/etc/OPIranPanel/password/$user" > /dev/null 2>&1

                if [[ -e /etc/openvpn/server.conf ]]; then
                    remove_ovp "$user"
                fi
                exit 1
            fi
        else
            tput setaf 7 ; tput setab 4 ; tput bold ; echo "" ; echo " The User $user does not exist!" ; echo "" ; tput sgr0
        fi
    fi

# Remove all users
elif [[ "$resp" = "2" ]]; then
    clear
    tput setaf 7 ; tput setab 4 ; tput bold ; printf '%32s%s%-13s\n' "ㅤㅤ🚮ㅤRemove SSH Userㅤ🚮ㅤㅤ" ; tput sgr0
    echo ""
    echo -ne "${YELLOW} YOU REALLY WANT TO REMOVE ALL USERS ${RESET}[${GREEN}s/n${RESET}]: "; read -r opc

    if [[ "$opc" = "s" ]]; then
        echo -e "\n${YELLOW} Please Wait...${GREEN}.${RED}.${CYAN}.${RESET}"
        for user in $(cat /etc/passwd | awk -F : '$3 > 900 {print $1}' | grep -vi "nobody"); do
            pkill -f "$user" > /dev/null 2>&1
            deluser --force "$user" > /dev/null 2>&1

            if [[ -e /etc/openvpn/server.conf ]]; then
                remove_ovp "$user"
            fi
        done

        rm "$HOME/users.db" && touch "$HOME/users.db"
        rm *.zip > /dev/null 2>&1
        echo -e "\n${GREEN}SUCCESSFULLY REMOVED USERS!${RESET}"
        sleep 2
        menu
    else
        echo -e "\n${RED}Returning to the menu...${RESET}"
        sleep 2
        menu
    fi

# Go back to the main menu
elif [[ "$resp" = "3" ]]; then
    menu
else
    echo -e "\n${RED}Invalid option!${RESET}"
    sleep 1.5s
    menu
fi
