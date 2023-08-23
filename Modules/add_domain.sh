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

domain_store_dir="/etc/OPIranPanel"
ipv4_domain_file="$domain_store_dir/ipv4_domain.txt"
ipv6_domain_file="$domain_store_dir/ipv6_domain.txt"

# Function to add domain/subdomain for IPV4
add_domain_ipv4() {
    echo -e "${YELLOW}Enter the domain/subdomain for IPV4${NC} :"
    read -r domain_ipv4
    if [[ -z "$domain_ipv4" ]]; then
        echo -e "${RED}No domain/subdomain provided for IPV4. Skipping...${NC}"
    else
        echo "$domain_ipv4" > "$ipv4_domain_file"
        echo -e "${GREEN}Domain/subdomain '$domain_ipv4' has been added for IPV4.${NC}"
    fi
}

# Function to add domain/subdomain for IPV6
add_domain_ipv6() {
    echo -e "${YELLOW}Enter the domain/subdomain for IPV6${NC} :"
    read -r domain_ipv6
    if [[ -z "$domain_ipv6" ]]; then
        echo -e "${RED}No domain/subdomain provided for IPV6. Skipping...${NC}"
    else
        echo "$domain_ipv6" > "$ipv6_domain_file"
        echo -e "${GREEN}Domain/subdomain '$domain_ipv6' has been added for IPV6.${NC}"
    fi
}

# Function to change or remove domain/subdomain for a given IP (IPV4 or IPV6)
change_or_remove_domain() {
    while true; do
        clear
        echo ""
        echo -e "       ${WHITE} Domain Modification ${NC}"
        echo ""
        echo -e "${RED} 1)${NC} => ${YELLOW}Change/Remove domain/subdomain for IPV4${NC}"
        echo -e "${RED} 2)${NC} => ${YELLOW}Change/Remove domain/subdomain for IPV6${NC}"
        echo -e "${RED} B)${NC} => ${YELLOW}Back${NC}"
        echo ""
        echo -e "${WHITE}What's Your Choice? ${NC}"

        read -r action

        case "$action" in
            1)
                echo ""
                echo -e "${RED} 1)${NC} => ${BLUE}Change Domain/Subdomain${NC}"
                echo -e "${RED} 2)${NC} => ${BLUE}Remove Domain/Subdomain${NC}"
                echo ""
                read -p "Select an option: " option_ipv4

                case "$option_ipv4" in
                    1)
                        read -p "Enter the new domain/subdomain for IPV4: " new_domain_ipv4
                        if [[ -z "$new_domain_ipv4" ]]; then
                            echo -e "${RED}No domain/subdomain provided for IPV4. Skipping...${NC}"
                        else
                            echo "$new_domain_ipv4" > "$ipv4_domain_file"
                            echo -e "${GREEN} New Domain/subdomain '$domain_ipv4' has been added for IPV4.${NC}"
                        fi
                        ;;
                    2)
                        echo "" > "$ipv4_domain_file"
                        echo -e "${RED}Domain/subdomain has been removed for IPV4.${NC}"
                        ;;
                    *)
                        echo -e "${RED}Invalid choice. Please select again.${NC}"
                        ;;
                esac
                ;;
            2)
                echo ""
                echo -e "${RED} 1)${NC} => ${BLUE}Change Domain/Subdomain${NC}"
                echo -e "${RED} 2)${NC} => ${BLUE}Remove Domain/Subdomain${NC}"
                echo ""
                read -p "Select an option: " option_ipv6

                case "$option_ipv6" in
                    1)
                        read -p "Enter the new domain/subdomain for IPV6 : " new_domain_ipv6
                        if [[ -z "$new_domain_ipv6" ]]; then
                            echo -e "${RED}No domain/subdomain provided for IPV6. Skipping...${NC}"
                        else
                            echo "$new_domain_ipv6" > "$ipv6_domain_file"
                            echo -e "${GREEN} New Domain/subdomain '$domain_ipv6' has been added for IPV6.${NC}"
                        fi
                        ;;
                    2)
                        echo "" > "$ipv6_domain_file"
                        echo -e "${RED}Domain/subdomain has been removed for IPV6.${NC}"
                        ;;
                    *)
                        echo -e "${RED}Invalid choice. Please select again.${NC}"
                        ;;
                esac
                ;;
            [Bb])
                break
                ;;
            *)
                echo -e "${RED}Invalid choice. Please select again.${NC}"
                ;;
        esac
    done
}

# Function to wait for user input before exiting
press_enter_to_continue() {
    echo -e "${YELLOW} Press.....${NC} ${RED} ENTER ${NC} ${YELLOW}.....to continue${NC}"
    read -s -r -p ""
    sleep 0.5
    add_domain
}

# Function to show the main menu
add_domain() {
    mkdir -p "$domain_store_dir"
    while true; do
    clear
    echo ""
    echo -e "       ${white} Add / Remove Domain  ${NC}"
    echo ""
    echo -e "${RED} 1)${NC} => ${YELLOW}Add domain/subdomain for IPV4${NC}"
    echo -e "${RED} 2)${NC} => ${YELLOW}Add domain/subdomain for IPV6${NC}"
    echo -e "${RED} 3)${NC} => ${YELLOW}Change or remove domain/subdomain${NC}"
    echo -e "${RED} M)${NC} => ${YELLOW}Menu${NC}"
    echo ""
    echo -e "${WHITE}Whats Your Choice? ${NC}"
    read -r choice

        case "$choice" in

            1) 
            clear
            add_domain_ipv4
            add_domain
            ;;
            2)
            clear
            add_domain_ipv6
            add_domain
            ;;
            3)
            clear
            change_or_remove_domain
            press_enter_to_continue
            ;;
            [Mm]) 
            break
            ;;
            *)
            echo -e "${RED}Invalid option. Please select again.${NC}"
            add_domain
            ;;
        esac
    done
}

# Call the add_domain function
add_domain
