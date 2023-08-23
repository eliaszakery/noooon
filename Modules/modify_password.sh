#!/bin/bash

# Color variables
NC="\033[0m"
RED="\033[1;31m"
YELLOW="\033[1;33m"
GREEN="\033[1;32m"
CYAN="\033[1;34m"
BOLD="\033[1m"

# Function to generate a random password
generate_random_pass() {
    local type=$1
    local length=$2
    if [[ $type -eq 1 ]]; then
        local chars=( {0..9} )
    elif [[ $type -eq 2 ]]; then
        local chars=({a..z} {0..9})
    elif [[ $type -eq 3 ]]; then
        local chars=({a..z} {A..Z} {0..9})
    fi
    local str=""

    for ((i = 0; i < $length; i++)); do
        local rand_idx=$((RANDOM % ${#chars[@]}))
        str+="${chars[$rand_idx]}"
    done

    echo "$str"
}

# Function to display the list of users and passwords
list_users() {
    echo -e "${YELLOW}USERS LIST AND PASSWORDS:${NC}"
    echo ""

    i=1
    while read user; do
        password_file="/etc/OPIranPanel/password/$user"
        if [[ -f $password_file ]]; then
            password="$(cat "$password_file")"
        else
            password="Null"
        fi

        suser="${RED}${i})${NC} ${GREEN}${user}${NC}"
        spassword="${YELLOW}Password${NC}: ${password}${NC}"

        printf '%-60s%s\n' "$suser" "$spassword"
        i=$((i + 1))
    done < <(awk -F: '$3>=1000 {print $1}' /etc/passwd | grep -v nobody)

    echo ""
}


# Function to modify passwords for multiple users
modify_bulkuser_password() {
    # Display header
    clear
    echo ""
    echo -e "    ${CYAN}Modify Bulk Users Password${NC}"
    echo ""

    # Display the list of bulk users
    echo -e "${YELLOW}List of Bulk Users:${NC}"
    echo ""
    cat /root/users.db | cut -d' ' -f1

    # Ask for user selection
    echo -ne "${YELLOW}Select a User to Modify Password: ${NC}"
    read selected_user

    if [[ -z "$selected_user" ]]; then
        echo ""
        echo -e "${RED}Error: Empty selection!${NC}"
        echo ""
        exit 1
    fi

    # Check if the selected user exists
    if ! grep -q "^$selected_user " /root/users.db; then
        echo ""
        echo -e "${RED}Error: Selected user does not exist!${NC}"
        echo ""
        exit 1
    fi

    # Ask for password option
    echo -e "${YELLOW}Password Option:${NC}"
    echo -e "${YELLOW}1)${NC} Constant Password"
    echo -e "${YELLOW}2)${NC} Random Password"
    read -p "Choose password option [1/2]: " password_option

    if [[ "$password_option" != "1" && "$password_option" != "2" ]]; then
        echo ""
        echo -e "${RED}Invalid option! Please select 1 or 2.${NC}"
        echo ""
        exit 1
    fi

    # Ask for password
    if [[ "$password_option" == "1" ]]; then
        echo -ne "${YELLOW}Enter the Constant Password for Bulk User $selected_user: ${NC}"
        read -s password
        echo ""
    else
        echo -ne "${YELLOW}Enter the Length of Random Password for Bulk User $selected_user: ${NC}"
        read password_length

        if [[ -z "$password_length" ]] || ! [[ "$password_length" =~ ^[0-9]+$ ]]; then
            echo ""
            echo ""
            echo -e "${RED}ERROR: Please enter a valid number.${NC}"
            echo ""
            exit 1
        fi

        # Generate random password
        password=$(generate_random_pass 3 "$password_length")
    fi

    # Update the user's password
    pass=$(perl -e 'print crypt($ARGV[0], $ARGV[1])' "$password" "$password")
    chpasswd <<< "$selected_user:$password"
    echo "$password" > "/etc/OPIranPanel/password/$selected_user"

    echo ""
    echo -e "${YELLOW}Password for bulk user $selected_user has been updated.${NC}"
    echo ""
}


# modify password single user
modify_singleuser_password() {
clear
echo ""
echo -e "     ${BOLD}${CYAN}MODIFY USER PASSWORD${NC}"
echo ""

list_users

num_user=$(awk -F: '$3>=1000 {print $1}' /etc/passwd | grep -v nobody | wc -l)
echo ""
echo -ne "${YELLOW}Enter or select a user ${NC} ${RED}[${NC}${GREEN}1-${num_user}${RED}]${NC} ${YELLOW} Or ${RED}[${NC}${GREEN}Type Username${RED}]${NC} : "
read option
selected_user=$(awk -F") " '{print $2}' <<< "$option")

if [[ -z $option ]]; then
    echo -e "${RED}Empty or invalid field!${NC}"
    exit 1
elif [[ -z $selected_user ]]; then
    echo -e "${RED}You entered an empty or invalid name!${NC}"
    exit 1
else
    if grep -q "/$selected_user:" /etc/passwd; then
        password_file="/etc/OPIranPanel/password/$selected_user"
        if [[ -f $password_file ]]; then
            password="$(cat "$password_file")"
        else
            password="Null"
        fi
        echo -ne "${YELLOW}New password for user${NC} ${RED}$selected_user${NC}: "
        read new_password
        sizepass=${#new_password}
        if [[ $sizepass -lt 4 ]]; then
            echo -e "${RED}Empty or invalid password! Use at least 4 characters${NC}"
            exit 1
        else
            ps x | grep "$selected_user" | grep -v grep | grep -v pt > /tmp/rem
            if [[ $(grep -c "$selected_user" /tmp/rem) -eq 0 ]]; then
                echo "$selected_user:$new_password" | chpasswd
                echo -e "${GREEN}User password $selected_user has been changed to: $new_password${NC}"
                echo "$new_password" > "/etc/OPIranPanel/password/$selected_user"
                exit 1
            else
                echo ""
                echo -e "${GREEN}User logged in. Disconnecting...${NC}"
                pkill -f "$selected_user"
                echo "$selected_user:$new_password" | chpasswd
                echo -e "${GREEN}User password $selected_user has been changed to: $new_password${NC}"
                echo "$new_password" > "/etc/OPIranPanel/password/$selected_user"
                exit 1
            fi
        fi
    else
        echo -e "${RED}The user $selected_user does not exist!${NC}"
        exit 1
    fi
fi
}
# Display the main menu
while true; do
    clear
    echo -e "${GREEN}────────────────────────────────────────────────────────${NC}"
    echo -e "         ${WHITE}───── Modify Password  ─────${NC}"
    echo -e "${RED}────────────────────────────────────────────────────────${NC}"
    echo ""
    echo -e "${RED} 1)${NC} => ${CYAN}Modify Password for Single User"
    echo -e "${RED} 2)${NC} => ${CYAN}Modify Bulk Password"
    echo -e "${RED} M)${NC} => ${CYAN}Main Menu${NC}"
    echo ""
    echo -e "${RED}────────────────────────────────────────────────────────${NC}"
    echo ""
    echo -ne "${YELLOW}${BOLD}Enter your choice [1-3]: ${NC}"
    read choice

    case $choice in
        1)
            # Call function to modify password for single user
            modify_singleuser_password
            continue
            ;;
        2)
            # Call function to modify password for bulk users
            modify_bulkuser_password
            continue
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
