#!/bin/bash

CYAN="\e[36m"
GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
NC="\e[0m"

display_menu() {
    clear
    echo -e "${GREEN}────────────────────────────────────────────────────────${NC}"
    echo -e "          ${GREEN}───── Manage IPtables  ─────${NC}"
    echo -e "${RED}────────────────────────────────────────────────────────${NC}"
    echo ""
    echo -e "${RED} 1)${NC} => ${CYAN}Install iptables${NC}"
    echo -e "${RED} 2)${NC} => ${CYAN}Display forwarding table${NC}"
    echo -e "${RED} 3)${NC} => ${CYAN}Set up a tunnel${NC}"
    echo -e "${RED} 4)${NC} => ${CYAN}Delete a tunnel${NC}"
    echo -e "${RED} M)${NC} => ${CYAN}Main Menu${NC}"
    echo " "
    echo -e "${RED}────────────────────────────────────────────────────────${NC}"
    echo -e "${YELLOW}Please choose an option:${NC}"
}

install_iptables() {
    sudo apt-get update
    sudo apt-get install -y iptables
    echo -e "Press ${RED}ENTER${NC} to continue"
    read
}

display_forwarding_table() {
    echo "Displaying Forwarding Table:"
    sudo iptables -t nat -L -n -v
    echo -e "Press ${RED}ENTER${NC} to continue"
    read
}

setup_tunnel() {
    echo "Please enter the Iran IP for the tunnel:"
    read iran_ip
    echo "Please enter the Kharej IP for the tunnel:"
    read kharej_ip
    echo "Please enter the SSH port (default is 22):"
    read ssh_port

    sudo sysctl net.ipv4.ip_forward=1
    sudo iptables -t nat -A PREROUTING -p tcp --dport "$ssh_port" -j DNAT --to-destination "$iran_ip"
    sudo iptables -t nat -A PREROUTING -j DNAT --to-destination "$kharej_ip"
    sudo iptables -t nat -A POSTROUTING -j MASQUERADE

    echo "Do you want to add the commands to crontab for automatic execution on server reboot? (y/n)"
    read add_to_crontab_choice
    if [[ "$add_to_crontab_choice" =~ ^[Yy]$ ]]; then
        (crontab -l ; echo "@reboot sudo sysctl net.ipv4.ip_forward=1 && sudo iptables -t nat -A PREROUTING -p tcp --dport $ssh_port -j DNAT --to-destination \"$iran_ip\" && sudo iptables -t nat -A PREROUTING -j DNAT --to-destination \"$kharej_ip\" && sudo iptables -t nat -A POSTROUTING -j MASQUERADE") | crontab -
        echo "The iptables commands have been added to the crontab for automatic execution on server reboot."
    fi

    echo -e "Press ${RED}ENTER${NC} to continue"
    read
}

delete_tunnel() {
    echo "Please enter the Iran IP for the tunnel to delete:"
    read iran_ip
    echo "Please enter the Kharej IP for the tunnel to delete:"
    read kharej_ip
    echo "Please enter the SSH port (default is 22):"
    read ssh_port

    sudo sysctl net.ipv4.ip_forward=1
    sudo iptables -t nat -D PREROUTING -p tcp --dport "$ssh_port" -j DNAT --to-destination "$iran_ip"
    sudo iptables -t nat -D PREROUTING -j DNAT --to-destination "$kharej_ip"
    sudo iptables -t nat -D POSTROUTING -j MASQUERADE

    echo -e "Press ${RED}ENTER${NC} to continue"
    read
}

main_menu() {
    echo -e "Press ${RED}ENTER${NC} to continue"
    read
    show_CONNECTION_PROTOCLE_submenu
}

while true; do
    iptable_menu
    read choice
    case $choice in
        1) install_iptables ;;
        2) display_forwarding_table ;;
        3) setup_tunnel ;;
        4) delete_tunnel ;;
        M) main_menu ;;
        *) echo -e "${RED}Invalid choice. Please choose a valid option.${NC}" ; read -p "Press Enter to continue..." ;;
    esac
done
