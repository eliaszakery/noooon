#!/bin/bash

CYAN="\e[36m"
WHITE="\e[37m"
GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
NC="\e[0m"

clear_screen() {
    clear
}

echo_title() {
    echo -e "${CYAN}Modify limit on connections${NC}"
}

echo_menu() {
    echo ""
    echo -e "${RED} 1)${NC} => ${CYAN}Modify limit for Single User"
    echo -e "${RED} 2)${NC} => ${CYAN}Modify Bulk limit"
    echo -e "${RED} M)${NC} => ${CYAN}Main Menu${NC}"
    echo ""
    echo -e "${RED}────────────────────────────────────────────────────────${NC}"
    echo ""
    echo -ne "${YELLOW}${BOLD}Enter your choice [1-3]: ${NC}"
    read choice
}

list_users() {
    echo -e "${YELLOW}USERS LIST AND LIMITS:${NC}"
    echo ""

    database="/root/users.db"
    i=0
    unset _userLimit

    while read user; do
        i=$((i + 1))
        _oP=$i
        [[ $i == [1-9] ]] && i=0$i

        limit=$(get_user_limit "$user")

        formatted_user_info=$(format_user_info "$i" "$user")
        printf '%-60s%s\n' "$formatted_user_info" "${YELLOW}Limit${WHITE}: $limit${NC}"

        _userLimit+="\n${_oP}:${user}"
    done < <(awk -F: '$3>=1000 {print $1}' /etc/passwd | grep -v nobody)

    echo ""
}

get_user_limit() {
    local user="$1"
    local limit
    if grep -q -w "$user" "$database"; then
        limit=$(grep -w "$user" "$database" | cut -d' ' -f2)
    else
        limit='1'
    fi
    echo "$limit"
}

user_exists() {
    local user="$1"
    cat /etc/passwd | grep -w "$user" > /dev/null
}

modify_singleuser_limit() {
    clear_screen
    echo ""
    echo -e "      ${CYAN}MODIFY LIMIT FOR SINGLE USER${NC}"
    echo ""

    list_users

    echo ""
    num_users=$(awk -F: '$3>=1000 {print $1}' /etc/passwd | grep -v nobody | wc -l)
    echo -ne "${YELLOW}Enter or select a user ${NC}${RED}[${NC}${GREEN}1-$num_users${NC}${RED}]${NC} ${YELLOW} Or ${NC}${RED}[${NC}${GREEN}Type Username${NC}${RED}]${NC} : "
    read selected_option
    selected_user=$(echo -e "${_userLimit}" | grep -E "\b$selected_option\b" | cut -d: -f2)

    if [[ -z $selected_option ]]; then
        echo -e "${RED}Empty or non-existent user${NC}"
        continue
    elif [[ -z $selected_user ]]; then
        echo -e "${RED}Empty or non-existent user${NC}"
        continue
    else
        if user_exists "$selected_user"; then
            echo -ne "\n${YELLOW}New limit for the user ${RED}$selected_user${NC}: "
            read ssh_limit

            if [[ -z $ssh_limit ]]; then
                echo -e "${RED}You entered an invalid number!${NC}"
                continue
            elif ! [[ "$ssh_limit" =~ ^[0-9]+$ ]]; then
                echo -e "${RED}You entered an invalid number!${NC}"
                continue
            elif [[ "$ssh_limit" -lt 1 ]]; then
                echo -e "${RED}You must enter a number greater than zero!${NC}"
                continue
            else
                grep -v "^$selected_user[[:space:]]" "$database" > /tmp/a
                mv /tmp/a "$database"
                echo "$selected_user $ssh_limit" >> "$database"
                echo -e "${GREEN}Limit applied to the user $selected_user for $ssh_limit ${NC}"
                continue
            fi
        else
            echo -e "${RED}The user $selected_user was not found${NC}"
            continue
        fi
    fi
}

modify_bulkuser_limit() {
    clear_screen
    echo ""
    echo -e "      ${CYAN}MODIFY LIMIT FOR BULK USERS${NC}"
    echo ""

    list_users

    echo ""
echo -ne "${YELLOW}Enter or select a user range ${RED}[${NC}${GREEN}1 to $num_users${NC}${RED}]${NC} ${YELLOW} Or ${NC}${RED}[${NC}${GREEN}1 $num_users${NC}${RED}]: "
read range
from_user=$(echo "$range" | cut -d ' ' -f 1)
to_user=$(echo "$range" | cut -d ' ' -f 2)

if [[ -z $from_user || -z $to_user ]]; then
    echo -e "${RED}Empty range!${NC}"
    continue
elif ! [[ "$from_user" =~ ^[0-9]+$ || "$to_user" =~ ^[0-9]+$ ]]; then
    echo -e "${RED}Invalid range format!${NC}"
    continue
elif [[ "$from_user" -lt 1 || "$from_user" -gt "$num_users" || "$to_user" -lt 1 || "$to_user" -gt "$num_users" ]]; then
    echo -e "${RED}Invalid user range!${NC}"
    continue
elif [[ "$from_user" -gt "$to_user" ]]; then
    echo -e "${RED}Invalid user range! The start must be less than or equal to the end.${NC}"
    continue
fi

    echo -ne "\n${YELLOW}New limit for the selected range (${RED}$from_user${NC}-${RED}$to_user${NC}): "
    read ssh_limit

    if [[ -z $ssh_limit ]]; then
        echo -e "${RED}You entered an invalid number!${NC}"
        continue
    elif ! [[ "$ssh_limit" =~ ^[0-9]+$ ]]; then
        echo -e "${RED}You entered an invalid number!${NC}"
        continue
    elif [[ "$ssh_limit" -lt 1 ]]; then
        echo -e "${RED}You must enter a number greater than zero!${NC}"
        continue
    fi

    awk -F: '$3>=1000 {print $1}' /etc/passwd | grep -v nobody | awk "NR >= $from_user && NR <= $to_user" | while read selected_user; do
        if user_exists "$selected_user"; then
            grep -v "^$selected_user[[:space:]]" "$database" > /tmp/a
            mv /tmp/a "$database"
            echo "$selected_user $ssh_limit" >> "$database"
            echo -e "${GREEN}Limit applied to the user $selected_user for $ssh_limit ${NC}"
        else
            echo -e "${RED}The user $selected_user was not found${NC}"
        fi
    done

    continue
}

# Display the main menu
while true; do
    clear_screen
    echo ""
    echo -e "         ${WHITE}───── Modify Limit  ─────${NC}"
    echo ""
    echo -e "${RED}────────────────────────────────────────────────────────${NC}"
    echo ""
    echo -e "${RED} 1)${NC} => ${CYAN}Modify limit for Single User"
    echo -e "${RED} 2)${NC} => ${CYAN}Modify limit for Bulk Users"
    echo -e "${RED} M)${NC} => ${CYAN}Main Menu${NC}"
    echo ""
    echo -e "${RED}────────────────────────────────────────────────────────${NC}"
    echo ""
    echo -ne "${YELLOW}${BOLD}Enter your choice [1-3]: ${NC}"
    read choice

    case $choice in
        1)
            modify_singleuser_limit
            ;;
        2)
            modify_bulkuser_limit
            ;;
        [Mm])
            echo -e "${GREEN}${BOLD}Exiting.${NC}"
            break
            ;;
        *)
            echo -e "${RED}Invalid choice. Please enter a valid option.${NC}"
            ;;
    esac
done
