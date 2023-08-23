#!/bin/bash

# Constants for color codes and formatting
NC="\033[0m"
CYAN="\033[1;34m"
RED="\033[1;31m"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
WHITE="\033[1;37m"
BOLD="\033[1m"

list_users() {
    echo -e "${YELLOW} USERS LIST AND EXPIRY DATE:${NC}"
    echo ""

    database="/root/users.db"
    i=0
    unset _userPass

    while read user; do
        i=$((i + 1))
        _oP=$i
        [[ $i == [1-9] ]] && i=0$i

        expire_date=""
        if is_account_expired "$user"; then
            expire_date="${RED}UNVALID${NC}"
        else
            expire_date="${GREEN}VALID${NC}"
        fi
        
        formatted_user_info=$(format_user_info "$i" "$user")
        printf '%-62s%-20s%s\n' "$formatted_user_info" "$expire_date"

        _userPass+="\n${_oP}:${user}"
    done < <(awk -F: '$3>=1000 {print $1}' /etc/passwd | grep -v nobody)

    echo ""
    if [ -a /tmp/exp ]; then
        rm /tmp/exp
    fi
}

# Function to format user information
format_user_info() {
    local index="$1"
    local user="$2"
    echo -e "${RED}[$index] ${WHITE}- ${GREEN}$user${WHITE}"
}

# Function to format expiry date
format_expiry_date() {
    local expire="$1"
    local today="$(date -d today +'%Y%m%d')"
    local databr="$(date -d "$expire" +'%Y%m%d')"

    if [ "$expire" == "never" ]; then
        echo -e "${YELLOW}00/00/0000   S/DATE ${NC}"
    elif [ "$today" -ge "$databr" ]; then
        echo -e "${RED}$(date -d "$expire" +'%d/%m/%Y')   ${YELLOW}UNVALID${NC}"
    else
        echo -e "${YELLOW}$(date -d "$expire" +'%d/%m/%Y')   ${GREEN}VALID${NC}"
    fi
}

is_bulk_user() {
    local username="$1"
    if grep -q -w "$username" "/root/users.db" && grep -q "$username" "/root/bulkusers-"*; then
        return 0 # User is a bulk user
    else
        return 1 # User is not a bulk user
    fi
}

is_bulk_user_not_logged_in() {
    local username="$1"
    if grep -q -w "$username" "/root/users.db" && (grep -q "$username" "/root/bulkusers-A"* || grep -q "$username" "/root/bulkusers-B"*); then
        if [ ! -f "/root/firstlogin/$username" ]; then
            return 0 # Bulk user hasn't logged in yet
        else
            return 1 # Bulk user has logged in
        fi
    else
        return 1 # User is not a bulk user or doesn't match the criteria
    fi
}

# Function to validate the input date
validate_date_input() {
    echo ""
    echo -e "${RED}EX:${NC}(DATE: ${GREEN}DAY/MONTH/YEAR ${YELLOW}OR ${GREEN}DAYS: ${YELLOW}30${NC})"
    echo ""
    echo -ne "${GREEN}ㅤNew date or days: ${NC}"; read inputdate

    if [[ "$(echo -e "$inputdate" | grep -c "/")" = "0" ]]; then 
        udata=$(date "+%d/%m/%Y" -d "+$inputdate days")
        sysdate="$(echo "$udata" | awk -v FS=/ -v OFS=- '{print $3,$2,$1}')"
    else
        udata=$(echo -e "$inputdate")
        sysdate="$(echo "$inputdate" | awk -v FS=/ -v OFS=- '{print $3,$2,$1}')"
    fi

    if (date "+%Y-%m-%d" -d "$sysdate" > /dev/null  2>&1); then
        if [[ -z $inputdate ]]; then
            echo ""
            echo -e "${RED}ㅤYou have entered an invalid or non-existent date!${NC}" ; echo -e "${YELLOW}Enter a valid date in DAY/MONTH/YEAR format ${NC}" ; echo -e "${GREEN}For example: 21/04/2023 ${NC}"
            echo ""
            continue   
        else
            if (echo $inputdate | egrep [^a-zA-Z] &> /dev/null); then
                today="$(date -d today +"%Y%m%d")"
                timemachine="$(date -d "$sysdate" +"%Y%m%d")"

                if [ $today -ge $timemachine ]; then
                    echo ""
                    echo -e "${RED}ㅤYou have entered an invalid or non-existent date!${NC}" ; echo -e "${YELLOW}Enter a valid date in DAY/MONTH/YEAR format ${NC}" ; echo -e "${GREEN}For example: 21/04/2023 ${NC}"
                    echo ""
                    continue
                else
                    echo "$sysdate"
                fi
            else
                echo ""
                echo -e "${RED}ㅤYou have entered an invalid or non-existent date!${NC}" ; echo -e "${YELLOW}Enter a valid date in DAY/MONTH/YEAR format ${NC}" ; echo -e "${GREEN}For example: 21/04/2023 ${NC}"
                echo ""
                continue
            fi
        fi
    else
        echo ""
        echo -e "${RED}ㅤYou have entered an invalid or non-existent date!${NC}" ; echo -e "${YELLOW}Enter a valid date in DAY/MONTH/YEAR format ${NC}" ; echo -e "${GREEN}For example: 21/04/2023 ${NC}"
        echo ""
        continue
    fi
}

# Function to change the expiry date for the selected user
change_expiry_date() {
    list_users

    if [ -a /tmp/exp ]; then
        rm /tmp/exp
    fi

    num_user=$(awk -F: '$3>=1000 {print $1}' /etc/passwd | grep -v nobody | wc -l)
    echo -ne "${GREEN}ㅤEnter or select user(s) (comma-separated) ${YELLOW}[${GREEN}1-${num_user}${YELLOW}]${WHITE}: "
    read options

    if [[ -z $options ]]; then
        echo ""
        echo -e "${RED}ㅤError: Empty or Invalid Selection!${NC}"
        return
    fi

    IFS=',' read -ra selected_users <<< "$options"
    
    for selected_user in "${selected_users[@]}"; do
        user=$(echo -e "${_userPass}" | grep -E "\b$selected_user\b" | cut -d: -f2)

        if [[ -z $user ]]; then
            echo ""
            echo -e "${RED}ㅤError: Invalid User - $selected_user${NC}"
            continue
        fi

        if grep -q "/$user:" /etc/passwd; then
    if is_bulk_user "$user"; then
        if is_bulk_user_not_logged_in "$user"; then
            # Handle setting the expiry date for first login of bulk user
            echo ""
            echo -e "${YELLOW}User is a bulk user and hasn't logged in yet."
            echo -e "You can set an expiration date for their first login.${NC}"
            echo -ne "${GREEN}ㅤNew date for the first login of bulk user ${YELLOW}$user: ${WHITE}"
            read inputdate
            sysdate=$(validate_date_input)  # Make sure to validate user input
            touch "/home/$user/.first_login"
            chage -E "$sysdate" "$user"
            echo ""
            echo -e "${GREEN}ㅤExpiry date set for the first login of bulk user $user: $(date -d "$sysdate" '+%d/%m/%Y') ${NC}"
            echo ""
        else
            # Handle setting the expiry date for logged-in bulk user
            echo ""
            echo -e "${RED}EX:${YELLOW}(DATE: ${GREEN}DAY/MONTH/YEAR ${YELLOW}OR ${GREEN}DAYS: ${WHITE}30${YELLOW})"
            echo ""
            echo -ne "${GREEN}ㅤNew date or days for the user ${YELLOW}$user: ${WHITE}"
            read inputdate
            sysdate=$(validate_date_input)  # Validate user input

            chage -E "$sysdate" "$user"
            echo ""
            echo -e "${GREEN}ㅤUser $user expiry date changed to: $(date -d "$sysdate" '+%d/%m/%Y') ${NC}"
            echo ""
        fi
    fi
        fi
done    
}

# Function to handle initial setup of bulk users' expiration dates
setup_bulkuser_expiry() {
    clear
    list_users

    if [ -a /tmp/exp ]; then
        rm /tmp/exp
    fi

    num_users=$(awk -F: '$3>=1000 {print $1}' /etc/passwd | grep -v nobody | wc -l)
    echo -ne "${YELLOW}ㅤEnter or select bulk users (comma-separated) ${RED}[${GREEN}1,${num_users}${RED}]${RED} (${GREEN}EX. 1 OR 1,2,3.. OR 1 2 3 ...${RED})${NC}: "
    read options

    if [[ -z $options ]]; then
        echo ""
        echo -e "${RED}ㅤError: Empty or Invalid Selection!${NC}"
        return
    fi

    IFS=',' read -ra bulk_users <<< "$options"
    
    for bulk_user in "${bulk_users[@]}"; do
        bulk_user=$(echo -e "${_userPass}" | grep -E "\b$bulk_user\b" | cut -d: -f2)

        if [[ -z $bulk_user ]]; then
            echo ""
            echo -e "${RED}ㅤError: Invalid Bulk User - $bulk_user${NC}"
            continue
        fi

        if is_bulk_user "$bulk_user"; then
            if is_bulk_user_not_logged_in "$bulk_user"; then
                echo ""
                echo -e "${RED}EX:${YELLOW}(DATE: ${GREEN}DAY/MONTH/YEAR ${YELLOW}OR ${GREEN}DAYS: ${WHITE}30${YELLOW})"
                echo ""
                echo -ne "${GREEN}ㅤExpiry date for the first login of bulk user ${YELLOW}$bulk_user: ${WHITE}"
                read inputdate
                sysdate=$(validate_date_input)
                touch "/home/$bulk_user/.first_login"
                chage -E "$sysdate" "$bulk_user"
                echo ""
                echo -e "${GREEN}ㅤExpiry date set for the first login of bulk user $bulk_user: $(date -d "$sysdate" '+%d/%m/%Y') ${NC}"
                echo ""
            else
                echo ""
                tput setaf 7 ; tput setab 1 ; tput bold ; echo "ㅤExpiry date for the first login of bulk user $bulk_user has already been set!" ; tput sgr0
                echo ""
            fi
        else
            echo ""
            echo -e "${RED} Error, The user $bulk_user is not a bulk user!${NC}"
            echo ""
        fi
    done
}

# Display the main menu
main_menu() {
    clear
    echo ""
    echo -e "  ${CYAN} Modify Expiry Date ${NC}"
    echo ""
    list_users

    num_user=$(awk -F: '$3>=1000 {print $1}' /etc/passwd | grep -v nobody | wc -l)
    echo -ne "${GREEN}ㅤEnter or select a user ${YELLOW}[${GREEN}1${YELLOW}-${GREEN}$num_user${YELLOW}]${WHITE}: "
    read option

    if [[ -z $option ]]; then
        echo ""
        echo -e "${RED}ㅤError, Empty or Invalid Username! ${NC}"
        continue
    fi

    selected_user=$(echo -e "${_userPass}" | grep -E "\b$option\b" | cut -d: -f2)

    if [[ -z $selected_user ]]; then
        echo ""
        echo -e "${RED}ㅤError, Empty or Invalid Username!!! ${NC}"
        echo ""
        continue
    else
        change_expiry_date "$selected_user"
    fi
}

# Menu loop
while true; do
    clear
    echo -e "${GREEN}────────────────────────────────────────────────────────${NC}"
    echo -e "         ${WHITE}───── Modify Expiry Date  ─────${NC}"
    echo -e "${RED}────────────────────────────────────────────────────────${NC}"
    echo ""
    echo -e "${RED} 1)${NC} => ${CYAN}Modify Expiry Date for Single User"
    echo -e "${RED} 2)${NC} => ${CYAN}Modify Expiry Date for Bulk Users"
    echo -e "${RED} M)${NC} => ${CYAN}Menu${NC}"
    echo ""
    echo -e "${RED}────────────────────────────────────────────────────────${NC}"
    echo ""
    echo -ne "${YELLOW}${BOLD}Enter your choice [1-2 / M]: ${NC}"
    read choice

    case $choice in
        1)
            # Call function to modify expiry date for single user
            main_menu
            ;;
        2)
            # Call function to modify expiry date for bulk users
            setup_bulkuser_expiry
            ;;
        [Mm])
            echo -e "${GREEN}${BOLD}Exiting.${NC}"
            break
            ;;
        *)
            echo -e "${RED}Invalid choice. Please enter a valid option.${NC}"
            continue
            ;;
    esac
done
