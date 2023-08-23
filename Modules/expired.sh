#!/bin/bash

CYAN="\e[1;36m"
GREEN="\e[1;32m"
RED="\e[1;31m"
YELLOW="\e[1;33m"
RESET="\e[0m"

expired_user="/etc/OPIranPanel/expired_user"
expired="/etc/OPIranPanel/Exp"

# Function to check if a user's account is expired
is_account_expired() {
    local username="$1"
    local expiration_date=$(chage -l "$username" | grep "Account expires" | awk -F ': ' '{print $2}')
    [[ "$expiration_date" != "never" && $(date +%s) -gt $(date -d "$expiration_date" +%s) ]]
}

# Main function to list users, check expiration, and present the table
main() {
    # Clear the expired_user file
    > "$expired_user"
    clear
    echo -e "${CYAN}USERNAME  EXP-STATUS        ACTION          DATE${NC}"
    echo -e "${CYAN}─────────────────────────────────────────────────────────${NC}"

    expired_users=0
    
    for _user in $(awk -F: '$3>=1000 {print $1}' /etc/passwd | grep -v nobody); do
        if is_account_expired "$_user"; then
            condition="$(tput setaf 1)✗$(tput sgr0)"
            action="DELETE"
            userdel -r "$_user"  # Delete user and their home directory
            echo "$_user" >> "$expired_user"
            expired_users=$((expired_users + 1))
        else
            condition="$(tput setaf 2)✔$(tput sgr0)"
            action="KEEP"
        fi
        tput bold; tput setaf 7
        printf "%-18s%-15s%s%-18s\n" "$_user" "$condition" "          $action" "            $(chage -l "$_user" | grep "Account expires" | awk -F ': ' '{print $2}')"
        tput sgr0
        tput bold; tput setaf 3
        echo "─────────────────────────────────────────────────────────"
        tput sgr0
    done
    
    echo -e "${GREEN}EXPIRED USERS${NC} =>  $(tput setaf 1)✗$(tput sgr0)"
    tput sgr0
    tput bold; tput setaf 3
    echo "─────────────────────────────────────────────────────────"
    tput sgr0
    
    # Store the count of expired users in the expired file
    echo "$expired_users" > "$expired"

    sleep 2
}

# Run the main function
main
