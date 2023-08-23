#!/bin/bash

# Color variables for better readability
WHITE="\e[37m"
BLUE="\e[34m"
MAGENTA="\e[35m"
GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
CYAN="\e[36m"
BLACK="\e[30m"
PINK="\e[38;5;206m"
ORANGE="\e[38;5;208m"
NC="\e[0m"

# Function to add a custom banner
add_banner() {
    local banner_file="/etc/bannerssh"
    echo -e "${YELLOW}Enter the banner text:${NC}"
    read -r banner_text

    if [[ -z "$banner_text" ]]; then
        echo -e "${RED}Error: Empty or invalid banner text!${NC}"
        sleep 2
        return
    fi
}
# Function to remove the custom banner
remove_banner() {
    local banner_file="/etc/bannerssh"
    echo " " > "$banner_file"
    echo -e "${GREEN}Banner removed successfully!${NC}"
    echo -e "${GREEN}Restarting SSH and Dropbear services...${NC}"
    service ssh restart > /dev/null 2>&1
    service dropbear restart > /dev/null 2>&1
    sleep 2
}

# Function to wait for user input before exiting
press_enter_to_continue() {
    echo -e "${YELLOW} Press.....${NC} ${RED} ENTER ${NC} ${YELLOW}.....to continue${NC}"
    read -s -r -p ""
    sleep 0.5
    return
}

# Main script execution
banner_menu() {
while true; do
    clear
    echo -e "${green}────────────────────────────────────────────────────────${NC}"
    echo -e "     ${red}    ─────── BANNER MANAGER ───────${NC}"
    echo -e "${green}────────────────────────────────────────────────────────${NC}"
    echo ""
    echo -e "${red}─────────────── Manuall Method ───────────────${NC}"
    echo ""
    echo -e "${YELLOW} Exit the menu with <CTRL+C> and run the following command:${NC}"
    echo -e "${RED}nano /etc/bannerssh${NC}"
    echo -e "${YELLOW} Write or Paste your banner Text then CTRL+X to save and exit${NC}"
    echo ""
    echo -e "${red}─────────────── OPIran Method ───────────────${NC}"
    echo ""
    echo -e "${RED}1)${NC} ${YELLOW}ADD BANNER${NC}"
    echo -e "${RED}2)${NC} ${YELLOW}REMOVE BANNER${NC}"
    echo -e "${RED}M)${NC} ${YELLOW}BACK${NC}"
    echo ""
    echo -e "${green}────────────────────────────────────────────────────────${NC}"
    echo ""
    echo -ne "${CYAN}WHATS YOUR CHOICE? : ${NC}"
    read -r response

    case "$response" in
        1)
            clear
            echo ""
            echo -e "${BLUE}Select the font size:${NC}"
            echo ""
            echo -e "${RED}1)${NC} ${YELLOW}Small Font Size${NC}"
            echo -e "${RED}2)${NC} ${YELLOW}Average Font Size${NC}"
            echo -e "${RED}3)${NC} ${YELLOW}Large Font Size${NC}"
            echo -e "${RED}4)${NC} ${YELLOW}Giant Font Size${NC}"
            echo -e "${RED}B)${NC} ${GREEN}Back${NC}"
            echo ""
            echo -e "${CYAN}WHATS YOUR CHOICE?${NC}"
            read -r font_size_option

        case "$font_size_option" in
            1) font_size="6" ;;
            2) font_size="4" ;;
            3) font_size="3" ;;
            4) font_size="1" ;;
            [Bb]) 
            banner_menu ;;
            *) echo -e "${RED}Error: Invalid font size option!${NC}" ; sleep 2 ; banner_menu ;;
        esac

            echo -e "${BLUE}Select the banner color:${NC}"
            echo ""
            echo -e "${RED}1)${NC} ${BLUE}Blue${NC}"
            echo -e "${RED}2)${NC} ${GREEN}Green${NC}"
            echo -e "${RED}3)${NC} ${RED}Red${NC}"
            echo -e "${RED}4)${NC} ${YELLOW}Yellow${NC}"
            echo -e "${RED}5)${NC} ${PINK}Pink${NC}"
            echo -e "${RED}6)${NC} ${CYAN}Cyan${NC}"
            echo -e "${RED}7)${NC} ${WHITE}White${NC}"
            echo -e "${RED}8)${NC} ${ORANGE}Orange${NC}"
            echo -e "${RED}9)${NC} ${MAGENTA}Purple${NC}"
            echo -e "${RED}10)${NC} ${BLACK}Black${NC}"
            echo ""
            echo -e "${CYAN}WHATS YOUR CHOICE?${NC}"
            read -r banner_color_option

            case "$banner_color_option" in

                    1) banner_color="BLUE" ;;
                    2) banner_color="GREEN" ;;
                    3) banner_color="RED" ;;
                    4) banner_color="YELLOW" ;;
                    5) banner_color="#F535AA" ;;
                    6) banner_color="CYAN" ;;
                    7) banner_color="WHITE" ;;
                    8) banner_color="#9932CD" ;;
                    9) banner_color="MAGENTA" ;;
                    10) banner_color="BLACK" ;;
                    [Bb]) 
                    banner_menu ;;
                    *) echo -e "${RED}Error: Invalid banner color option!${NC}" ; sleep 2 ; banner_menu ;;
                    esac

        echo "<h$font_size><font color='$banner_color'>$banner_text</font></h$font_size>" > "$banner_file"
        echo -e "${GREEN}Banner added successfully!${NC}"
        echo -e "${GREEN}Restarting SSH and Dropbear services...${NC}"
        service ssh restart > /dev/null 2>&1
        service dropbear restart > /dev/null 2>&1
        sleep 2
        press_enter_to_continue
         ;;
        2) 
        remove_banner 
        press_enter_to_continue
        ;;
        [Mm]) 
        echo -e "${YELLOW} Press.....${NC} ${RED} ENTER ${NC} ${YELLOW}.....to Back to the Menu${NC}"
        read -s -r -p ""
        sleep 0.5
        break
        ;;
        *) echo -e "${RED}Invalid option!${NC}"
        press_enter_to_continue
        ;;
    esac
    done
}
banner_menu
