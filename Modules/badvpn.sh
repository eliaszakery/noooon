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

check_screen() {
    if ! command -v screen &> /dev/null; then
        echo -e "${YELLOW}${BOLD}The 'screen' package is not installed.${NC}"
        echo -e "${CYAN}Trying to install 'screen' package...${NC}"
        apt-get update -y >/dev/null 2>&1
        apt-get install screen -y >/dev/null 2>&1
        if [ $? -ne 0 ]; then
            echo -e "${RED}${BOLD}Failed to install 'screen'. Using 'nohup' instead.${NC}"
            return 1
        else
            echo -e "${GREEN}${BOLD}'screen' package installed successfully.${NC}"
        fi
    fi
    return 0
}

stop_badvpn() {
    if pgrep -x "badvpn-udpgw" > /dev/null; then
        pkill -x badvpn-udpgw
        sleep 1
        if command -v screen &> /dev/null; then
            screen -wipe >/dev/null
        fi
        echo ""
        echo -e "${GREEN}${BOLD} BADVPN SUCCESSFULLY DISABLED!${NC}"
        sleep 3
        badvpn_menu
    else
        echo ""
        echo -e "${RED} BadVPN is not running!${NC}"
        badvpn_menu
    fi
}

start_badvpn() {
    install_badvpn
    if check_screen; then
        screen -dmS udpvpn /bin/badvpn-udpgw --listen-addr 127.0.0.1:7300 --max-clients 200 --max-connections-for-client 8
        sleep 1
        echo ""
        echo -e "${GREEN}${BOLD} SUCCESSFULLY ACTIVATED BADVPN${NC}"
    else
        nohup /bin/badvpn-udpgw --listen-addr 127.0.0.1:7300 --max-clients 200 --max-connections-for-client 8 >/dev/null 2>&1 &
        sleep 1
        echo ""
        echo -e "${GREEN}${BOLD} SUCCESSFULLY ACTIVATED BADVPN (Using nohup)${NC}"
    fi
    sleep 3
    badvpn_menu
}

install_badvpn() {
    if [[ ! -e "/bin/badvpn-udpgw" ]]; then
        wget -q https://github.com/opiran-club/opiran-panel/raw/main/Install/badvpn-udpgw -O /bin/badvpn-udpgw
        chmod +x /bin/badvpn-udpgw
    fi
}

# Function to add a port to BadVPN
add_port() {
    if pgrep -x "badvpn-udpgw" > /dev/null; then
        port="$1"
        if [[ -z "$port" ]]; then
            echo ""
            echo -e "${RED} Invalid port!"
            sleep 1
        else
            screen_exists=1
            if command -v screen &> /dev/null; then
                screen -S udpvpn -p 0 -X stuff "^C"
                screen -S udpvpn -X quit
                screen -dmS udpvpn /bin/badvpn-udpgw --listen-addr 127.0.0.1:"$port" --max-clients 200 --max-connections-for-client 8
                echo ""
                echo -e "${GREEN}${BOLD} Port $port has been added to BadVPN${NC}"
            else
                screen_exists=0
                nohup /bin/badvpn-udpgw --listen-addr 127.0.0.1:"$port" --max-clients 200 --max-connections-for-client 8 >/dev/null 2>&1 &
                echo ""
                echo -e "${GREEN}${BOLD} Port $port has been added to BadVPN (Using nohup)${NC}"
            fi
            
            if [[ $screen_exists -eq 1 ]]; then
                sleep 1
                continue
            fi
        fi
    else
        echo ""
        echo -e "${RED} BadVPN is not running!${NC}"
        continue
    fi
}

badvpn_menu() {
    clear
    if pgrep -x "badvpn-udpgw" > /dev/null; then
    echo ""
        echo -e "${CYAN} PORTS${NC} ${MAGENTA}=>${NC} ${GREEN}$(netstat -nplt | awk '/badvpn-ud/ {print $4}' | cut -d: -f2 | xargs)${NC}"
    fi
    
    if pgrep -x "badvpn-udpgw" > /dev/null; then
    echo ""
        echo -e "${CYAN}BADVPN STATUS${NC} ${MAGENTA}=>${NC} ${GREEN}✔️"
    else
        echo -e "${CYAN}BADVPN STATUS${NC} ${MAGENTA}=>${NC} ${RED}❌"
    fi
    echo ""
    echo -e "${WHITE}${BOLD}        BADVPN MANAGER         ${NC}"
    echo ""
    echo -e "${RED}1)${NC} ${YELLOW}INSTALL & ACTIVATE${NC}"
    echo -e "${RED}2)${NC} ${YELLOW}ADD / REMOVE PORTS${NC}"
    echo -e "${RED}M)${NC} ${YELLOW}BACK${NC}"
    echo ""
    
    read -p "WHAT DO YOU WANT TO DO?" choice
    
    case "$choice" in
        1)
            if pgrep -x "badvpn-udpgw" > /dev/null; then
                stop_badvpn
            else
                start_badvpn
            fi
            ;;
        2)
        if pgrep -x "badvpn-udpgw" > /dev/null; then
            clear
            echo ""
            echo -ne "${CYAN} WHICH PORT YOU WANT TO USE?${NC}"
            read -r port
            add_port "$port"
            continue
        else
            clear
            echo -e "${RED} UNAVAILABLE FUNCTION ${YELLOW}ACTIVATE BADVPN FIRST!${NC}"
            sleep 2
            continue
        fi
        ;;
        [Mm])
            echo ""
            echo -e "${RED} Returning...${NC}"
            sleep 1
            break
            ;;
        *)
            echo ""
            echo -e "${RED} Invalid option!${NC}"
            sleep 1
            continue
            ;;
    esac
}
badvpn_menu
