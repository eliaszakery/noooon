#!/bin/bash

BLUE="\e[34m"
MAGENTA="\e[35m"
BOLD=$(tput bold)
CYAN="\e[36m"
WHITE="\e[37m"
GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
NC="\e[0m"

# Function to display active test users
display_active_test_users() {
        clear
        echo -e "    ${YELLOW} Create SSH User ${RESET}"
        echo ""
    if [ "$(ls -A /etc/OPIranPanel/usertest)" ]; then
        echo -e "\033[1;32mActive Test Users:\033[1;37m"
        for testeson in $(ls /etc/OPIranPanel/usertest | sort | sed 's/.sh//g'); do
            echo "$testeson"
        done
    else
        echo -e "\033[1;31mNo active test users!\033[0m"
    fi
}

# Function to check input values
check_input() {
    local input_var="$1"
    local error_message="$2"

    if [[ -z "$input_var" ]]; then
        echo ""
        tput setaf 7 ; tput setab 1 ; tput bold ; echo "" ; echo "$error_message" ; echo "" ; tput sgr0
        exit 1
    fi
}

# Check if the 'usertest' directory exists and create it if not
if [ ! -d "/etc/OPIranPanel/usertest" ]; then
    mkdir -p /etc/OPIranPanel/usertest
fi

# Display active test users
display_active_test_users

# Prompt for username, password, and connection limit
echo ""
echo -ne "${GREEN}Username: ${WHITE}"; read -r nome
check_input "$nome" "Empty or invalid name."

# Check if the username already exists
awk -F : '{ print $1 }' /etc/passwd > /tmp/users
if grep -Fxq "$nome" /tmp/users; then
    tput setaf 7 ; tput setab 1 ; tput bold ; echo "" ; echo "This user already exists." ; echo "" ; tput sgr0
    exit 1
fi

echo -ne "${GREEN}Password: ${WHITE}"; read -r pass
check_input "$pass" "Empty or invalid password."

echo -ne "${GREEN}Limit: ${WHITE}"; read -r limit
check_input "$limit" "Empty or invalid limit."

echo -ne "${GREEN}Minutes (Ex: 60): ${YELLOW}"; read -r u_temp
check_input "$u_temp" "Empty or invalid time limit."

# Create the user and set the password
useradd -M -s /bin/false "$nome"
(echo "$pass"; echo "$pass") | passwd "$nome" > /dev/null 2>&1
echo "$pass" > "/etc/OPIranPanel/password/$nome"
echo "$nome $limit" >> "/root/users.db"

# Create a script to delete the user after the specified time
cat > "/etc/OPIranPanel/usertest/$nome.sh" << EOF
#!/bin/bash
pkill -f "$nome"
userdel --force "$nome"
grep -v "^$nome[[:space:]]" "/root/users.db" > /tmp/ph
cat /tmp/ph > "/root/users.db"
rm "/etc/OPIranPanel/password/$nome" > /dev/null 2>&1
rm -rf "/etc/OPIranPanel/usertest/$nome.sh"
exit
EOF
chmod +x "/etc/OPIranPanel/usertest/$nome.sh"
at -f "/etc/OPIranPanel/usertest/$nome.sh" now + "$u_temp" min > /dev/null 2>&1

# Function to get ports and IP
IPV4=$(wget -qO- ipv4.icanhazip.com)
IPV6=$(curl -6 ifconfig.co 2>/dev/null)
openssh_port=$(grep -oP '^Port \K\d+' /etc/ssh/sshd_config | head -1)
dropbear_port=$(netstat -nplt | grep 'dropbear' | awk -F ":" '{print $4}' | xargs)
[ -z "$dropbear_port" ] && dropbear_port="N/A"

badvpn_port=$(netstat -nplt | grep 'badvpn-ud' | awk {'print $4'} | cut -d: -f2 | xargs)
[ -z "$badvpn_port" ] && badvpn_port="N/A"
IP=$(wget -qO- ipv4.icanhazip.com)
IP6=$(curl -6 ifconfig.co 2>/dev/null)

if [[ ! -f "$ipv4_domain_file" || -z "$domainv4" ]]; then
    domainv4="$IP"
fi

if [[ ! -f "$ipv6_domain_file" || -z "$domainv6" ]]; then
    domainv6="$IP6"
fi

# Check if a domain is available
if [[ -n "$domainv4" ]]; then
    echo "Domain: $domainv4"
elif [[ -n "$domainv6" ]]; then
    echo "Domain: $domainv6"
elif [[ -n "$IP6" ]]; then
    echo "IPv6: $IP6"
else
    echo "IPv6: N/A"
    echo "IPv4: $IP"
fi

clear
echo -e "${GREEN}TEST / HOURLY User created successfully with the following details:${RESET}"
echo -e "${MAGENTA}Username${RESET} ${YELLOW}=>${RESET} ${CYAN}$nome${RESET}"
echo -e "${MAGENTA}Password${RESET} ${YELLOW}=>${RESET} ${CYAN}$pass ${RESET}"
echo -e "${MAGENTA}Days to expire${RESET} ${YELLOW}=>${RESET} ${CYAN}$u_temp${RESET}"
echo -e "${MAGENTA}Limit of connections${RESET} ${YELLOW}=>${RESET} ${CYAN}$limit${RESET}"
echo -e "${MAGENTA}IPV4${RESET} ${YELLOW}=>${RESET} $IPV4${RESET}"
echo -e "${MAGENTA}IPV6${RESET} ${YELLOW}=>${RESET} ${IPV6:-N/A}${RESET}"
echo ""
echo -e "${GREEN}─────────────────────────────────────────────────────────────${RESET}"
echo -e "${WHITE}  ────────── OPIRAN PANEL ──────────  ${RESET}"
echo -e "${RED}─────────────────────────────────────────────────────────────${RESET}"
echo ""
echo -e "${WHITE}────────────⪧ HOST DETAILES ⪦────────────${RESET}"
echo ""
echo -e "${GREEN}◈ Host/IPV6   ${YELLOW}=>${RESET}  ${CYAN}$domainv6${RESET}"
echo -e "${GREEN}◈ Host/IPV4   ${YELLOW}=>${RESET}  ${CYAN}$domainv4${RESET}"
echo ""
echo -e "${WHITE}────────────⪧ ACCOUNT DETAILES ⪦────────────${RESET}"
echo ""
echo -e "${GREEN}◈ Username    ${YELLOW}=>${RESET}  ${CYAN}$nome${RESET}"
echo -e "${GREEN}◈ Password    ${YELLOW}=>${RESET}  ${CYAN}$pass${RESET}"
echo ""
echo -e "${WHITE}────────────⪧ PORTS INFO ⪦────────────${RESET}"
echo ""
echo -e "${GREEN}◈ SSH       ${YELLOW}=>${RESET}  ${CYAN}$openssh_port${RESET}"
echo -e "${GREEN}◈ DropBear  ${YELLOW}=>${RESET}  ${CYAN}$dropbear_port${RESET}"
echo -e "${GREEN}◈ BadVPN    ${YELLOW}=>${RESET}  ${CYAN}$badvpn_port${RESET}"
echo ""
echo -e "${WHITE}────────────⪧ EXPIRE / LIMIT ⪦────────────${RESET}"
echo ""
echo -e "${GREEN}◈ Login Limit ${YELLOW}=>${RESET}  ${CYAN}$limit${RESET}"
echo -e "${GREEN}◈ Expire Date ${YELLOW}=>${RESET}  ${CYAN}$u_temp minutes${RESET}"
echo ""
echo -e "${RED}─────────────────────────────────────────────────────────────"
echo -e "${YELLOW}©️        TEST / HOURLY USER ACCOUNT  "
echo -e "${WHITE}©️   Credited By OPIranCluB Visit Us @OPIranCluB  "
echo -e "${RED}─────────────────────────────────────────────────────────────"
echo ""
echo -e "${YELLOW}After the defined time, the user ${GREEN}$nome${RESET} will be disconnected and deleted.${RESET}"
# Function to wait for user input before exiting
press_enter_to_continue() {
    echo -e "${YELLOW} Press.....${NC} ${RED} ENTER ${NC} ${YELLOW}.....For Tip!${NC}"
    read -s -r -p ""
    sleep 2
}

# Call the press_enter_to_continue function to wait for user input
press_enter_to_continue

# Call the main menu
EDIT_SSH_ACCOUNTS_MENU_submenu
