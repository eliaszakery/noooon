#!/bin/bash

# Function to turn off the firewall
fun_fireoff() {
  iptables -P INPUT ACCEPT
  iptables -P OUTPUT ACCEPT
  iptables -P FORWARD ACCEPT
  iptables -t mangle -F
  iptables -t mangle -X
  iptables -t nat -F
  iptables -t nat -X
  iptables -t filter -F
  iptables -t filter -X
  iptables -F
  iptables -X
  rm "$arq"
  sleep 3
}

# Function to apply firewall rules
apply_firewall_rules() {
  # Default policies
  iptables -P INPUT DROP
  iptables -P FORWARD DROP
  iptables -P OUTPUT ACCEPT

  # Allow loopback traffic
  iptables -A INPUT -i lo -j ACCEPT
  iptables -A OUTPUT -o lo -j ACCEPT

  # Allow established and related connections
  iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
  iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

  # Allow DNS (tcp/udp port 53)
  iptables -A OUTPUT -p tcp --dport 53 -m state --state NEW -j ACCEPT
  iptables -A OUTPUT -p udp --dport 53 -m state --state NEW -j ACCEPT

  # Allow DHCP (tcp/udp port 67)
  iptables -A OUTPUT -p tcp --dport 67 -m state --state NEW -j ACCEPT
  iptables -A OUTPUT -p udp --dport 67 -m state --state NEW -j ACCEPT

  # Allow BitTorrent ports (tcp/udp 6881:6889)
  iptables -A INPUT -p tcp --dport 6881:6889 -j ACCEPT
  iptables -A INPUT -p udp --dport 6881:6889 -j ACCEPT
  iptables -A OUTPUT -p tcp --dport 6881:6889 -j ACCEPT
  iptables -A OUTPUT -p udp --dport 6881:6889 -j ACCEPT

  # Block BitTorrent traffic using string matching
  iptables -A FORWARD -m string --algo bm --string "BitTorrent" -j DROP
  iptables -A FORWARD -m string --algo bm --string "BitTorrent protocol" -j DROP
  iptables -A FORWARD -m string --algo bm --string "peer_id=" -j DROP
  iptables -A FORWARD -m string --algo bm --string ".torrent" -j DROP
  iptables -A FORWARD -m string --algo bm --string "announce.php?passkey=" -j DROP
  iptables -A FORWARD -m string --algo bm --string "torrent" -j DROP
  iptables -A FORWARD -m string --algo bm --string "announce" -j DROP
  iptables -A FORWARD -m string --algo bm --string "info_hash" -j DROP
  iptables -A FORWARD -m string --string "get_peers" --algo bm -j DROP
  iptables -A FORWARD -m string --string "announce_peer" --algo bm -j DROP
  iptables -A FORWARD -m string --string "find_node" --algo bm -j DROP
  
  echo 'iptables -A FORWARD -m string --string "find_node" --algo bm -j DROP' >> "$arq"
  sleep 2
  chmod +x "$arq"
  /etc/Plus-torrent > /dev/null 2>&1
}

# Function to remove firewall rules
remove_firewall_rules() {
  arq="/etc/Plus-torrent"
  iptables -P INPUT ACCEPT
  iptables -P OUTPUT ACCEPT
  iptables -P FORWARD ACCEPT
  iptables -t mangle -F
  iptables -t mangle -X
  iptables -t nat -F
  iptables -t nat -X
  iptables -t filter -F
  iptables -t filter -X
  iptables -F
  iptables -X
  rm "$arq"
  sleep 3
}

echo -e "\E[44;1;37m        ㅤㅤTORRENT BLOCK FIREWALLㅤㅤ        \E[0m"
echo ""

# Check for root privileges
if [[ $EUID -ne 0 ]]; then
  echo "This script requires root privileges. Please run it as root."
  exit 1
fi

IP=$(wget -qO- ipv4.icanhazip.com)
arq="/etc/block-torrent"

# Main script
echo -e "\033[1;31m[\033[1;33m!\033[1;31m]\033[1;33m ATTENTION! USE AT YOUR OWN RISKS\033[0m"
echo ""
read -p "$(echo -ne "\033[1;32m WISH TO APPLY FIREWALL RULES ? \033[1;33m[y/n]:\033[1;37m") " -e -i n resp

# Apply or remove firewall rules based on user input
if [[ "$resp" = 'y' ]]; then
  echo ""
  echo -ne "\033[1;33m TO CONTINUE, CONFIRM YOUR IP: \033[1;37m"
  read -e -i "$IP" userIP
  if [[ -z "$userIP" ]]; then
    echo ""
    echo -e "\033[1;31m◇ Invalid IP\033[1;32m"
    sleep 1
    echo ""
    read -p " Enter your IP / Domain: " userIP
  fi
  echo ""
  sleep 1
  echo -ne "\033[1;32m APPLYING FIREWALL\033[1;32m.\033[1;33m.\033[1;31m. \033[1;32m"
  apply_firewall_rules
  echo -e "\e[1D DONE."
  echo ""
  echo -e "\033[1;33m TORRENT BLOCK APPLIED!\033[0m"
  echo ""
  echo -e "\033[1;32m FIREWALL SUCCESSFULLY APPLIED! FOR BETTER FUNCTION, RESTART YOUR VPS"
  sleep 3
elif [[ -e "$arq" ]]; then
  read -p "$(echo -e "\033[1;32m WANT TO REMOVE FIREWALL RULES? \033[1;33m[y/n]:\033[1;37m") " -e -i n resp
  if [[ "$resp" = 'y' ]]; then
    echo ""
    echo -ne "\033[1;31m REMOVING FIREWALL\033[1;32m.\033[1;33m.\033[1;31m. \033[1;32m"
    fun_fireoff
    echo -e "\e[1DOk"
    echo ""
    echo -e "\033[1;33m TORRENT RELEASED!\033[0m"
    echo ""
    echo -e "\033[1;32m SUCCESSFULLY REMOVED FIREWALL !"
    echo ""
    if [[ -e /etc/openvpn/openvpn-status.log ]]; then
      echo -e "\033[1;31m[\033[1;33m!\033[1;31m]\033[1;33m RESTART THE SYSTEM TO COMPLETE"
      echo ""
      read -p "$(echo -e "\033[1;32m RESTART NOW \033[1;31m? \033[1;33m[y/n]:\033[1;37m ")" -e -i y respost
      echo ""
      if [[ "$respost" = 'y' ]]; then
        echo -ne "\033[1;31m Restarting"
        for i in $(seq 1 1 5); do
          echo -n "."
          sleep 01
        done
        echo ""
        reboot
      fi
    fi
    sleep 2
    show_MENU2_submenu
  else
    sleep 1
    show_MENU2_submenu
  fi
else
  sleep 1
  show_MENU2_submenu
fi
