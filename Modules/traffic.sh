#!/bin/bash
CYAN="\e[36m"
GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
CYAN="\e[36m"
NC="\e[0m"

# Function to calculate data usage in gigabytes
calculate_data_usage() {
  local bytes="$1"
  local gb=$(echo "scale=2; $bytes / (1024 * 1024 * 1024)" | bc)
  echo "$gb"
}

# Function to check if user data usage is already set
is_user_data_limit_set() {
  local username="$1"
  local uid=$(id -u "$username")
  if iptables -t mangle -L OUTPUT -n | grep -q "$uid"; then
    return 0
  else
    return 1
  fi
}

# Function to check user data usage
check_user_data_usage() {
  local username="$1"
  local uid=$(id -u "$username")
  local data_usage=$(iptables -nvx -L OUTPUT -t mangle | awk -v user="$uid" '$11 == user { sum += $2 } END { print sum }')

  if [ -z "$data_usage" ]; then
    echo "[WARNING] No data usage found for user $username"
    data_usage=0
  fi

  local usage_gb=$(calculate_data_usage "$data_usage")
  echo "User $username data usage: $usage_gb GB"
}

# Function to set the user data usage limit
set_user_data_limit() {
  local username="$1"
  local limit="$2"

  # Set up iptables rules for traffic accounting
  local uid=$(id -u "$username")
  iptables -t mangle -A OUTPUT -m owner --uid-owner "$uid" -j MARK --set-mark 1
  iptables -t mangle -A OUTPUT -m owner --uid-owner "$uid" -j RETURN
  iptables -t mangle -A PREROUTING -i tun0 -m mark --mark 1 -j RETURN
  iptables -t mangle -A PREROUTING -i eth0 -m mark --mark 1 -j DROP

  # Set up iproute2 rules for traffic accounting
  ip rule add fwmark 1 lookup 100
  ip route add local default dev lo table 100

  echo "Data limit of $limit GB set for user $username"
}

# Main script
  while true; do
    echo -e "${GREEN}Data Usage Menu:${NC}"
    echo -e "  (A) Check Data Usage"
    echo -e "  (B) Set Data Limit"
    echo -e "  (M) Main Menu"
    echo -e "  (E) Exit"
    echo -e "${GREEN}Please enter your choice:${NC}"
    read -r option

  case "$option" in
    [Aa])
        read -p "Enter the username: " username
        if is_user_data_limit_set "$username"; then
          check_user_data_usage "$username"
        else
          echo -e "[WARNING] No data limit is set for user $username"
        fi
        ;;
      [Bb])
        read -p "Enter the username: " username
        if is_user_data_limit_set "$username"; then
          echo -e "[INFO] Data limit is already set for user $username"
        else
          read -p "Enter the monthly data limit in gigabytes: " limit
          if ! [[ "$limit" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
            echo -e "[ERROR] Invalid data limit format: $limit"
          else
            set_user_data_limit "$username" "$limit"
          fi
        fi
        ;;
      [Mm])
        echo -e "${green} Lets Go To Main Menu${NC}, ${yellow} Press Enter ....${NC}"
        read
        clear
        sleep 1
        menu
        ;;
      [Ee])
        echo -e "${RED}Exiting...${NC}"
        exit ;;
      *)
        echo -e "${RED}[ERROR] Invalid option selected${NC}"
        ;;
    esac
  done
