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

# Function to get listening ports
get_listening_ports() {
  openssh_port=$(grep -oP '^Port \K\d+' /etc/ssh/sshd_config | head -1)
  dropbear_port=$(netstat -nplt | grep 'dropbear' | awk -F ":" '{print $4}' | xargs)
  if [[ -z "$dropbear_port" ]]; then
    dropbear_port="N/A"
  fi
  badvpn_port=$(netstat -nplt | grep 'badvpn-ud' | awk {'print $4'} | cut -d: -f2 | xargs)
  if [[ -z "$badvpn_port" ]]; then
    badvpn_port="N/A"
  fi
}

# Function to validate the input
validate_input() {
    local message="$1"
    local regex="$2"
    local error_msg="$3"
    read -p "$message" input
    [[ -z $input || ! $input =~ $regex ]] && {
        color_msg 1 "Error: $error_msg"
        exit 1
    }
}

# Display header
clear
echo -e "    ${YELLOW} Create SSH User ${RESET}"
echo ""

# Read and validate username
validate_input $'\033[1;32mUsername:\033[1;37m ' '^[a-zA-Z0-9]+$' "Invalid username! Do not use spaces, accents, or special characters."
username="$input"

# Read and validate password
validate_input $'\033[1;32mPassword:\033[1;37m ' '.{2,}' "Invalid or empty password! Password should be at least 2 characters long."
password="$input"

# Read and validate days to expire
validate_input $'\033[1;32mDays to expire:\033[1;37m ' '^[1-9][0-9]*$' "Invalid number of days! It should be a positive integer."
days="$input"

# Read and validate limit of connections
validate_input $'\033[1;32mLimit of connections:\033[1;37m ' '^[1-9][0-9]*$' "Invalid number of connections! It should be a positive integer."
sshlimiter="$input"

# Create the user
useradd -e "$days" -M -s /bin/false -p "$(perl -e 'print crypt($ARGV[0], "password")' "$password")" "$username" >/dev/null 2>&1
echo "$password" >/etc/OPIranPanel/password/"$username"
echo "$username $sshlimiter" >>/root/users.db

# Display the user details and Function to get ports and IP
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
echo -e "${GREEN}User created successfully with the following details:${RESET}"
echo -e "${MAGENTA}Username${RESET} ${YELLOW}=>${RESET} ${CYAN}$username${RESET}"
echo -e "${MAGENTA}Password${RESET} ${YELLOW}=>${RESET} ${CYAN}$password ${RESET}"
echo -e "${MAGENTA}Days to expire${RESET} ${YELLOW}=>${RESET} ${CYAN}$days${RESET}"
echo -e "${MAGENTA}Limit of connections${RESET} ${YELLOW}=>${RESET} ${CYAN}$sshlimiter${RESET}"
echo -e "${MAGENTA}IPV4${RESET} ${YELLOW}=>${RESET} $IPV4${RESET}"
echo -e "${MAGENTA}IPV6${RESET} ${YELLOW}=>${RESET} ${IPV6:-N/A}${RESET}"
echo ""
echo -e "${GREEN}─────────────────────────────────────────────────────────────${RESET}"
echo -e "${WHITE}  ㅤ      ─────────── OPIRAN PANEL ───────────  ${RESET}"
echo -e "${RED}─────────────────────────────────────────────────────────────${RESET}"
echo ""
echo -e "${MAGENTA}────────────⪧ HOST DETAILES ⪦────────────${RESET}"
echo ""
echo -e "${GREEN}◈ Host/IPV6   =>  ${RED}[${CYAN}${IP6:-N/A}${RED}]${RESET}"
echo -e "${GREEN}◈ Host/IPV4   =>  ${CYAN}$IP${RESET}"
echo ""
echo -e "${MAGENTA}────────────⪧ ACCOUNT DETAILES ⪦────────────${RESET}"
echo ""
echo -e "${GREEN}◈ Username    =>  ${CYAN}$username${RESET}"
echo -e "${GREEN}◈ Password    =>  ${CYAN}$password${RESET}"
echo ""
echo -e "${MAGENTA}────────────⪧ PORTS INFO ⪦────────────${RESET}"
echo ""
echo -e "${GREEN}◈ SSH       =>  ${CYAN}$openssh_port${RESET}"
echo -e "${GREEN}◈ DropBear  =>  ${CYAN}$dropbear_port${RESET}"
echo -e "${GREEN}◈ BadVPN    =>  ${CYAN}$badvpn_port${RESET}"
echo ""
echo -e "${MAGENTA}────────────⪧ EXPIRE / LIMIT ⪦────────────${RESET}"
echo ""
echo -e "${GREEN}◈ Login Limit =>  ${CYAN}$sshlimiter${RESET}"
echo -e "${GREEN}◈ Expire Date =>  ${CYAN}$days${RESET}"
echo ""
echo -e "${RED}─────────────────────────────────────────────────────────────"
echo -e "${WHITE}©️   Credited By OPIranCluB Visit Us @OPIranCluB  "
echo -e "${RED}─────────────────────────────────────────────────────────────"

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
