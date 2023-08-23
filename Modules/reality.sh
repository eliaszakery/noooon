#!/bin/bash

CYAN="\e[36m"
GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
white="\e[37m"
NC="\e[0m"    
    
 # Function to read user input with default value
function read_input {
    read -p "$1 [$2]: " input
    echo "${input:-$2}"
}

# Function to read user choice from a list of options
function read_choice {
    PS3="$1: "
    select choice in "${@:2}"; do
        if [[ -n $choice ]]; then
            echo "$choice"
            break
        fi
    done
}

# Function to start the script with default options
function quick_start {
    bash <(curl -sL https://raw.githubusercontent.com/aleskxyz/reality-ezpz/master/reality-ezpz.sh)
}

# Function to run the script with user inputs
function manual_configuration {
    transport=$(read_choice "Select transport protocol" "tcp" "http" "grpc" "ws")
    domain=$(read_input "Enter domain to use as SNI" "www.google.com")
    server=$(read_input "Enter IP address or domain name of server" "")
    core=$(read_choice "Select core" "sing-box" "xray")
    security=$(read_choice "Select type of TLS encryption" "reality" "letsencrypt" "selfsigned")
    menu=$(read_input "Show menu? (y/n)" "n")

    bash <(curl -sL https://raw.githubusercontent.com/aleskxyz/reality-ezpz/master/reality-ezpz.sh) \
        -t "$transport" \
        -d "$domain" \
        --server "$server" \
        -c "$core" \
        --security "$security"
}

# Function to manage the script configuration
function manage_configuration {
    while true; do
        clear
    echo -e "${green}────────────────────────────────────────────────────────${NC}"
    echo -e "       ${white}───── Reality Panel Menu  ─────${NC}"
    echo -e "${RED}────────────────────────────────────────────────────────${NC}"
    echo ""
    echo -e "${RED} 1)${NC} => ${CYAN}Add User${NC}"
    echo -e "${RED} 2)${NC} => ${CYAN}List Users${NC}"
    echo -e "${RED} 3)${NC} => ${CYAN}Delete User${NC}"
    echo -e "${RED} 4)${NC} => ${CYAN}Show Server Configuration${NC}"
    echo -e "${RED} 5)${NC} => ${CYAN}Enable Telegram Bot${NC}"
    echo -e "${RED} 6)${NC} => ${CYAN}Restore Default Configuration${NC}"
    echo -e "${RED} 7)${NC} => ${CYAN}Restart Services${NC}"
    echo -e "${RED} 8)${NC} => ${CYAN}Enable SafeNet${NC}"
    echo -e "${RED} 9)${NC} => ${CYAN}Enable Cloudflare Warp${NC}"
    echo -e "${RED}10)${NC} => ${CYAN}Show Script Menu${NC}"
    echo -e "${RED}11)${NC} => ${CYAN}Back${NC}"
    echo ""
    echo -e "${RED}────────────────────────────────────────────────────────${NC}"
        read -p "Enter your choice [1-11]: " realitychoice
        case $realitychoice in
            1)
                add_user=$(read_input "Enter username for new user")
                bash <(curl -sL https://raw.githubusercontent.com/aleskxyz/reality-ezpz/master/reality-ezpz.sh) \
                    --add-user "$add_user"
                ;;
            2)
                bash <(curl -sL https://raw.githubusercontent.com/aleskxyz/reality-ezpz/master/reality-ezpz.sh) \
                    --list-users
                ;;
            3)
                delete_user=$(read_input "Enter username to delete")
                bash <(curl -sL https://raw.githubusercontent.com/aleskxyz/reality-ezpz/master/reality-ezpz.sh) \
                    --delete-user "$delete_user"
                ;;
            4)
                bash <(curl -sL https://raw.githubusercontent.com/aleskxyz/reality-ezpz/master/reality-ezpz.sh) \
                    --show-server-config
                ;;
            5)
                tgbot_token=$(read_input "Enter Telegram bot token")
                tgbot_admins=$(read_input "Enter Telegram bot admins (comma separated list of usernames without leading '@')")
                bash <(curl -sL https://raw.githubusercontent.com/aleskxyz/reality-ezpz/master/reality-ezpz.sh) \
                    --enable-tgbot "$tgbot_token" --tgbot-token "$tgbot_token" --tgbot-admins "$tgbot_admins"
                ;;
            6)
                bash <(curl -sL https://raw.githubusercontent.com/aleskxyz/reality-ezpz/master/reality-ezpz.sh) \
                    --default
                ;;
            7)
                bash <(curl -sL https://raw.githubusercontent.com/aleskxyz/reality-ezpz/master/reality-ezpz.sh) \
                    --restart
                ;;
            8)
                bash <(curl -sL https://raw.githubusercontent.com/aleskxyz/reality-ezpz/master/reality-ezpz.sh) \
                    --enable-safenet
                ;;
            9)
                bash <(curl -sL https://raw.githubusercontent.com/aleskxyz/reality-ezpz/master/reality-ezpz.sh) \
                    --enable-warp
                ;;
            10)
                bash <(curl -sL https://raw.githubusercontent.com/aleskxyz/reality-ezpz/master/reality-ezpz.sh) \
                    -m
                ;;
            11)
                break
                ;;
            *)
                echo "Invalid choice."
                ;;
        esac
    done
}
              while true
                 do
                clear
                echo -e "${green}────────────────────────────────────────────────────────${NC}"
                echo -e "    ${white}───── Reality Manager (XRAY/SINGBOX)  ─────${NC}"
                echo -e "${RED}────────────────────────────────────────────────────────${NC}"
                echo ""
                echo -e "${RED} 1)${NC} => ${CYAN}Quick Start${NC}"
                echo -e "${RED} 2)${NC} => ${CYAN}Manual Configuration${NC}"
                echo -e "${RED} 3)${NC} => ${CYAN}Manage Configuration${NC}"
                echo -e "${RED} 4)${NC} => ${CYAN}Reality Panel Menu${NC}"
                echo ""
                echo -e "${RED}────────────────────────────────────────────────────────${NC}"
                echo ""
                echo -e "${RED} M)${NC} => ${CYAN}Main Menu${NC}"
                echo ""
                echo -e "${RED}────────────────────────────────────────────────────────${NC}"
                echo ""
                read -p "Enter your choice [1-4]: " choice
                case $choice in

                    1)
                        quick_start
                        ;;
                    2)
                        manual_configuration
                        ;;
                    3)
                        manage_configuration
                        ;;
                    4)
                        bash <(curl -sL https://raw.githubusercontent.com/aleskxyz/reality-ezpz/master/reality-ezpz.sh) --m
                        ;;
                    5)
                        exit 0
                        ;;
                    *)
                        echo "Invalid choice. Press Enter to continue..."
                        read
                        ;;
                esac
            done
