#!/bin/bash

CYAN="\e[36m"
GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
NC="\e[0m"

while true; do
                clear
                echo -e "${green}────────────────────────────────────────────────────────${NC}"
                echo -e "       ${white}───── V2ray Panels  ─────${NC}"
                echo -e "${RED}────────────────────────────────────────────────────────${NC}"
                echo ""
                echo -e "${RED} 1)${NC} => ${CYAN}hossein assadi's x-ui${NC}"
                echo -e "${RED} 2)${NC} => ${CYAN}vaxilu (original)${NC}"
                echo -e "${RED} 3)${NC} => ${CYAN}hiddify${NC}"
                echo -e "${RED} 4)${NC} => ${CYAN}alireza0 x-ui${NC}"
                echo -e "${RED} 5)${NC} => ${CYAN}3x-ui (MHSanaei)${NC}"
                echo -e "${RED} 6)${NC} => ${CYAN}kafka x-ui${NC}"
                echo -e "${RED} 7)${NC} => ${CYAN}alireza0 x-ui${NC}"
                echo -e "${RED} M)${NC} => ${CYAN}Main Menu${NC}"
                echo -e""
                echo -e "${RED}────────────────────────────────────────────────────────${NC}"
                echo ""
                read -p "Enter option number: " panel_choice

              case $panel_choice in
                1)
                    echo -e "${GREEN}Installing panel...${NC}"
                    echo ""
                    bash <(curl -Ls https://raw.githubusercontent.com/hossinasaadi/x-ui/master/install.sh)
                    ;;
                2)  
                    echo -e "${GREEN}Installing panel...${NC}"
                    echo ""
                    bash <(curl -Ls https://raw.githubusercontent.com/vaxilu/x-ui/master/install.sh)
                    ;;
                
                3) 
                    echo -e "${GREEN}Installing panel...${NC}"
                    echo ""
                    bash -c "$(curl -Lfo- https://raw.githubusercontent.com/hiddify/hiddify-config/main/common/download_install.sh)"
                    ;;
            
            
                4)
                    echo -e "${GREEN}Installing panel...${NC}"
                    echo ""  
                    bash <(curl -Ls https://raw.githubusercontent.com/alireza0/x-ui/master/install.sh)
                    ;;
                5)
                    echo -e "${GREEN}Installing panel...${NC}"
                    echo "" 
                    bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh)
                    ;;
                6)
                    echo -e "${GREEN}Installing panel...${NC}"
                    echo "" 
                    bash <(curl -Ls https://raw.githubusercontent.com/FranzKafkaYu/x-ui/master/install.sh)
                    ;;
                7)
                  
                    echo -e "${GREEN}Installing docker and downloading panel...${NC}"
                    sudo bash -c "$(curl -sL https://github.com/Gozargah/Marzban-scripts/raw/master/marzban.sh)" @install
                    marzban cli admin create --sudo
                    ;;
                M)
                    echo -e "Press ${RED}ENTER${NC} to continue"
                    read
                    menu
                    ;;
                *)
                    echo "Invalid panel choice"
                    ;;
                esac
            done
            echo -e "Press ${RED}ENTER${NC} to continue"
            read
            menu
          ;;