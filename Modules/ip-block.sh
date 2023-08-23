#!/bin/bash

# Color variables for dark mode
RED=$(tput setaf 1)       # Dark red
YELLOW=$(tput setaf 3)    # Dark yellow
CYAN=$(tput setaf 6)      # Dark cyan
GREEN=$(tput setaf 2)     # Dark green
BLUE=$(tput setaf 4)      # Dark blue
MAGENTA=$(tput setaf 5)   # Magenta
WHITE=$(tput setaf 7)     # White
BOLD=$(tput bold)
RESET=$(tput sgr0)

# Function to block IPs from a specific country
block_country_ips() {
  country_code="$1"
  echo "${yellow}Blocking IPs from $country_code${reset}"
  curl -sSL "https://www.ipdeny.com/ipblocks/data/countries/$country_code.zone" | awk '{print "sudo ufw deny out from any to " $1}' | bash
}

# Install required packages
apt update
apt install ufw libapache2-mod-geoip geoip-database -y
a2enmod geoip
apt install geoip-bin -y

# Open desired ports
ufw allow ssh
ufw allow http
ufw allow https

clear
# Ask the user which country IPs to block
echo "${yellow}Which country IPs do you want to block?${reset}"
echo "${red}1${reset}${yellow})${reset} ${cyan}Iran${reset}"
echo "${red}2${reset}${yellow})${reset} ${cyan}China${reset}"
echo "${red}3${reset}${yellow})${reset} ${cyan}Russia${reset}"
echo "${red}M${reset}${yellow})${reset} ${cyan}Main Menu${reset}"

read -p "Enter the number of your choice (1/2/3): " choice

case "$choice" in
  1)
    block_country_ips "ir"
    ;;
  2)
    block_country_ips "cn"
    ;;
  3)
    block_country_ips "ru"
    ;;
  M)
    echo -e "Press${red} Enter ${reset}To Get back to the Main Menu"
    read
    show_MENU2_submenu
    ;;
  *)
    echo "${red}Invalid choice. Exiting...${reset}"
    exit 1
    ;;
esac

# Ask the user whether to enable the firewall or not
read -p "${yellow}Do you want to enable the firewall${reset} ${red}(without enabling ufw the function wont work correctly)${reset}? ${yellow}(yes/no):${reset} " enable_firewall

if [[ "$enable_firewall" == "yes" ]]; then
  ufw enable
else
  echo "${red}Firewall remains disabled.${reset}"
fi

# Set up a cronjob to update the zone every 1 month
(crontab -l ; echo "0 0 1 * * curl -sSL https://www.ipdeny.com/ipblocks/data/countries/$country_code.zone | awk '{print \"sudo ufw deny out from any to \" \$1}' | bash") | crontab -
