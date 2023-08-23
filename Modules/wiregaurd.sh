#!/bin/bash

CYAN="\e[36m"
GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
NC="\e[0m"

              while true
                 do
                clear
                echo -e "${green}────────────────────────────────────────────────────────${NC}"
                echo -e "        ${white}───── WIREGAURD  ─────${NC}"
                echo -e "${RED}────────────────────────────────────────────────────────${NC}"
                echo ""
                echo -e "${RED} 1)${NC} => ${CYAN}Install WireGuard${NC}"
                echo -e "${RED} 2)${NC} => ${CYAN}Update WireGuard${NC}"
                echo -e "${RED} 3)${NC} => ${CYAN}Backup Users${NC}"
                echo -e "${RED} 4)${NC} => ${CYAN}Main Menu${NC}"
                echo ""
                echo -e "${RED}────────────────────────────────────────────────────────${NC}"

                read -p "Enter your choice [1-4]: " choice
                case $choice in
            1)        
                while true
                do
                clear
                echo -e "${green}────────────────────────────────────────────────────────${NC}"
                echo -e "       ${white}───── INSTALL WIREGAURD MENU  ─────${NC}"
                echo -e "${RED}────────────────────────────────────────────────────────${NC}"
                echo ""
                echo -e "${RED} 1)${NC} => ${CYAN}Install without SSL${NC}"
                echo -e "${RED} 2)${NC} => ${CYAN}Install with SSL${NC}"
                echo -e "${RED} 3)${NC} => ${CYAN}Wiregaurd menu${NC}"
                echo ""
                echo -e "${RED}────────────────────────────────────────────────────────${NC}"
                echo ""
                read -p "Enter your choice [1-3]: " install_choice
            
                            case $install_choice in
                                1)
                                    # Install WireGuard without SSL
                                    echo "Installing WireGuard without SSL..."
                                     if ! command -v docker &> /dev/null
                                    then
                                        echo "docker not found, installing..."
                                        curl -sSL https://get.docker.com | sh
                                        sudo usermod -aG docker $(whoami)
                                    fi
                                    # Prompt user for required information
                                    read -p "Enter IP address or domain name of server running Wireguard: " WG_HOST
                                    read -p "Enter admin password for Vase login: " PASSWORD
                                    read -p "Enter UDP port to use for Wireguard (default: 51820): " UDP_PORT
                                    UDP_PORT=${UDP_PORT:-51820}
                                    read -p "Enter TCP port to use for Wireguard (default: 51821): " TCP_PORT
                                    TCP_PORT=${TCP_PORT:-51821}
                                    
                                    # Run docker command with specified parameters
                                    docker run -d \
                                      --name=wg-easy \
                                      -e WG_HOST=$WG_HOST \
                                      -e PASSWORD=$PASSWORD \
                                      -v ~/.wg-easy:/etc/wireguard \
                                      -p $UDP_PORT:$UDP_PORT/udp \
                                      -p $TCP_PORT:$TCP_PORT/tcp \
                                      --cap-add=NET_ADMIN \
                                      --cap-add=SYS_MODULE \
                                      --sysctl="net.ipv4.conf.all.src_valid_mark=1" \
                                      --sysctl="net.ipv4.ip_forward=1" \
                                      --restart unless-stopped \
                                      weejewel/wg-easy

                                    read -p "Installation complete. Press enter to continue..."
                                    ;;
                                2)
                                    # Install WireGuard with SSL
                                    echo "Installing WireGuard with SSL..."
                                    # Installing required dependencies
                                    sudo apt install lsb-release ca-certificates apt-transport-https software-properties-common -y
                                    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
                                    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
                                    apt update -y 
                                     if ! command -v docker &> /dev/null
                                    then
                                        echo "docker not found, installing..."
                                        sudo apt install docker-ce -y
                                    fi
                                    echo"checking the docker.."
                                    sudo systemctl status docker
                                    sleep 1
                                    
                                    mkdir -p ~/.docker/cli-plugins/
                                    curl -SL https://github.com/docker/compose/releases/download/v2.5.0/docker-compose-linux-x86_64 -o ~/.docker/cli-plugins/docker-compose
                                    chmod +x ~/.docker/cli-plugins/docker-compose
                                    docker compose version
                                    sleep 1
                                    filepath="/root/compose-dir/docker-compose.yml"
                                    read -p "Enter IP address or domain name of server running Wireguard: " WG_HOST 
                                    read -p "Enter admin password for Vase login: " PASSWORD 
                                    echo"version: "3.8"
                                    services:
                                      wg-easy:
                                        environment:
                                          # ?? Change the server's hostname (clients will connect to):
                                          - WG_HOST=$WG_HOST
                                    
                                          # ?? Change the Web UI Password:
                                          - PASSWORD=$PASSWORD
                                        image: weejewel/wg-easy
                                        container_name: wg-easy
                                        hostname: wg-easy
                                        volumes:
                                          - ~/.wg-easy:/etc/wireguard
                                        ports:
                                          - "51820:51820/udp"
                                        restart: unless-stopped
                                        cap_add:
                                          - NET_ADMIN
                                          - SYS_MODULE
                                        sysctls:
                                          - net.ipv4.ip_forward=1
                                          - net.ipv4.conf.all.src_valid_mark=1
                                    
                                      nginx:
                                        image: weejewel/nginx-with-certbot
                                        container_name: nginx
                                        hostname: nginx
                                        ports:
                                          - "80:80/tcp"
                                          - "443:443/tcp"
                                        volumes:
                                          - ~/.nginx/servers/:/etc/nginx/servers/
                                          - ./.nginx/letsencrypt/:/etc/letsencrypt/
                                    	  
                                    	  "> "$filepath"
                                         
                                         file2path="/root/compose-dir/wg-easy.conf"
                                        echo"server {
                                                 
                                             	listen 80 default_server;
                                             	server_name $WG_HOST;
                                             	
                                                 location / {
                                                     proxy_pass http://wg-easy:51821/;
                                                     proxy_http_version 1.1;
                                                     proxy_set_header Upgrade $http_upgrade;
                                                     proxy_set_header Connection "Upgrade";
                                                     proxy_set_header Host $host;
                                                 }
                                             }
                                             " > "$file2path"
                                    apt install docker-compose -y
                                    docker-compose up -d         
                                    cd ~/compose-dir 
                                    cp docker-compose.yml ~/.nginx/servers/
                                    cp wg-easy.conf ~/.nginx/servers/
                                    read -p "Enter Email you want to get certificate with : " email
                                    # Run Docker command
                                    docker exec -it nginx sh -c "certbot --nginx --non-interactive --agree-tos -m $email -d $WG_HOST && nginx -s reload"
     
                                    read -p "Installation complete. Press enter to continue..."
                                    ;;
                                3)
                                    # Back to main menu
                                    break
                                    ;;
                                *)
                                 echo -e "${RED}Invalid choice. Please choose a valid option.${NC}" ; read -p "Press Enter to continue..." ;;
                            esac
                        done
                        ;;
                    2)
                        # Update WireGuard
                        echo "Updating WireGuard..."
                        cp ~/.wg-easy/wg0.conf /root
                        cp ~/.wg-easy/wg0.json /root 
                        docker stop wg-easy
                        docker rm wg-easy
                        docker pull weejewel/wg-easy
                        # Prompt user for required information
                        read -p "Enter IP address or domain name of server running Wireguard: " WG_HOST
                        read -p "Enter admin password for Vase login: " PASSWORD
                        read -p "Enter UDP port to use for Wireguard (default: 51820): " UDP_PORT
                        UDP_PORT=${UDP_PORT:-51820}
                        read -p "Enter TCP port to use for Wireguard (default: 51821): " TCP_PORT
                        TCP_PORT=${TCP_PORT:-51821}
                        
                        # Run docker command with specified parameters
                 
                        docker run -d \
                          --name=wg-easy \
                          -e WG_HOST=$WG_HOST \
                          -e PASSWORD=$PASSWORD \
                          -v ~/.wg-easy:/etc/wireguard \
                          -p $UDP_PORT:$UDP_PORT/udp \
                          -p $TCP_PORT:$TCP_PORT/tcp \
                          --cap-add=NET_ADMIN \
                          --cap-add=SYS_MODULE \
                          --sysctl="net.ipv4.conf.all.src_valid_mark=1" \
                          --sysctl="net.ipv4.ip_forward=1" \
                          --restart unless-stopped \
                          weejewel/wg-easy
                        read -p "Update complete. Press enter to continue..."
                        ;;
                    3)
                        # Backup Users
                        echo "Backing up wg0 users on root ..."
                        cp ~/.wg-easy/wg0.conf /root
                        cp ~/.wg-easy/wg0.json /root 
                        read -p "Backup complete. Press enter to continue..."
                        ;;
                    4)
                        # Exit
                        echo "Goodbye!"
                        break
                        ;;
                    *)
                     echo -e "${RED}Invalid choice. Please choose a valid option.${NC}" ; read -p "Press Enter to continue..." ;;
                esac
            done
            echo -e "Press ${RED}ENTER${NC} to continue"
            read 
            show_CONNECTION_PROTOCLE_submenu
           ;;