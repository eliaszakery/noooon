#!/bin/bash

# Color Variables
BLUE="\e[34m"
MAGENTA="\e[35m"
BOLD=$(tput bold)
CYAN="\e[36m"
WHITE="\e[37m"
GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
NC="\e[0m"

# Exit on error
set -e

# Check root access
check_root() {
  if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}Please run this script as root!${NC}"
    exit 1
  fi
}

# Fix DNS
fix_dns() {
  DNS_PATH="/etc/resolv.conf"

  if [[ ! -w "$DNS_PATH" ]]; then
    echo -e "${RED}Error: Cannot modify $DNS_PATH. Check permissions or run with root privileges.${NC}"
    exit 1
  fi

  sed -i '/^nameserver/d' "$DNS_PATH"
  echo 'nameserver 8.8.8.8' >> "$DNS_PATH"
  echo 'nameserver 1.1.1.1' >> "$DNS_PATH"
  echo -e "${GREEN}System DNS Optimized.${NC}"
}

# Check OS compatibility
check_os() {
  supported_os=("debian" "ubuntu")
  current_os=$(grep -i pretty_name /etc/os-release 2>/dev/null | cut -d \" -f2 | tr '[:upper:]' '[:lower:]')

  for os in "${supported_os[@]}"; do
    if [[ "$current_os" =~ $os ]]; then
      return 0
    fi
  done

  echo -e "${RED}Your OS is not supported. Supported OS: Debian, Ubuntu, CentOS, Alpine, Arch.${NC}"
  exit 1
}

# Install necessary packages
install_packages() {
  case "$current_os" in
    debian|ubuntu)
      apt -y update && apt -y install wget net-tools
      ;;
  esac

  if [[ $? -ne 0 ]]; then
    echo -e "${RED}Error installing packages. Check your internet connection.${NC}"
    exit 1
  fi
}

# Update & Upgrade & Remove & Clean
complete_update() {
  apt update
  apt -y upgrade
  sleep 0.5
  apt -y dist-upgrade
  apt -y autoremove
  apt -y autoclean
  apt -y clean
}

# Main menu
main_menu() {
  while true; do
  clear
  echo ""
    echo -e "       ${cyan}CFWARP MENU${NC}"
    echo""
    echo -e "${RED}1)${NC} ${YELLOW}Install WARP socks5 proxy${NC}"
    echo -e "${RED}2)${NC} ${YELLOW}Account Type (free, plus, team)${NC}"
    echo -e "${RED}3)${NC} ${YELLOW}Turn on/off WireProxy${NC}"
    echo -e "${RED}4)${NC} ${YELLOW}Uninstall WARP${NC}"
    echo -e "${RED}M)${NC} ${YELLOW}Menu${NC}"
    echo ""
    read -p "WHAT DO YOU WANT TO DO? " response

    case "$response" in
      1)
        check_os
        check_root
        fix_dns
        complete_update
        install_packages
        wget -N -P /etc/wireguard https://raw.githubusercontent.com/fscarmen/warp/main/menu.sh
        chmod +x /etc/wireguard/menu.sh
        ln -sf /etc/wireguard/menu.sh /usr/bin/warp
        echo -e "${GREEN}WireProxy installed successfully."
        ;;
      2)
        warp a
        ;;
      3)
        warp y
        ;;
      4)
        warp u
        ;;
      [Mm])
        echo -e "${RED}Returning..."
        sleep 2
        menu
        ;;
      *)
        echo -e "${RED}Invalid choice"
        main_menu
        ;;
    esac
  done
}
# Start the main menu
main_menu
