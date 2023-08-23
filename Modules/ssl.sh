#!/bin/bash

CYAN="\e[36m"
GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
CYAN="\e[36m"
NC="\e[0m"

inst_ssl() {
		if netstat -nltp | grep 'stunnel4' 1>/dev/null 2>/dev/null; then
        [[ $(netstat -nltp | grep 'stunnel4' | wc -l) != '0' ]] && sslt=$(netstat -nplt | grep stunnel4 | awk {'print $4'} | awk -F ":" {'print $2'} | xargs) || sslt="\033[1;31mINDISPONIVEL"
            echo -e "${green}────────────────────────────────────────────────────────${NC}"
            echo -e "        ${white}───── SSL Tunnels  ─────${NC}"
            echo -e "${RED}────────────────────────────────────────────────────────${NC}"
            echo ""
            echo -e "${CYAN} PORTS${NC}=> ${yellow}$sslt${NC}"
            echo ""
            echo -e "${RED} 1)${NC} => ${CYAN}CHANGE PORT SSL TUNNEL${NC}"
            echo -e "${RED} 2)${NC} => ${CYAN}REMOVE SSL TUNNEL${NC}"
            echo -e "${RED} 3)${NC} => ${CYAN}COME BACK${NC}"
            echo ""
            echo -e "${RED}────────────────────────────────────────────────────────${NC}"
            echo -ne "${yellow}WHAT DO YOU WANT TO DO ?${NC} "
            read response
            echo ""
        case "$response" in
			1)
                # User wants to change the SSL tunnel port
                echo -ne "${yellow}WHICH PORT YOU WANT TO USE ?${NC} "
                read porta
                echo ""
                [[ -z "$port" ]] && {
                    echo ""
                    echo -e "${red}Invalid port!${NC}"
                    sleep 2
                    clear
                    inst_ssl
                }
                verif_ptrs $port
                echo -e "${green}CHANGING PORT SSL TUNNEL!${NC}"
                var2=$(grep 'accept' /etc/stunnel/stunnel.conf | awk '{print $NF}')
                sed -i "s/\b$var2\b/$port/g" /etc/stunnel/stunnel.conf >/dev/null 2>&1
                echo ""
                fun_bar 'sleep 2'
                echo ""
                echo -e "${yellow}RESETTING SSL TUNNEL!${NC}"
                fun_bar 'service stunnel4 restart' '/etc/init.d/stunnel4 restart'
                echo ""
                netstat -nltp | grep 'stunnel4' >/dev/null && echo -e "${green}SUCCESSFULLY CHANGED PORT!${NC}" || echo -e "${red}mUNEXPECTED ERROR!${NC}"
                sleep 3.5s
                clear
                inst_ssl
                ;;
            2)
                # User wants to remove the SSL tunnel
                echo -e "${yellow}REMOVING SSL TUNNEL !${nc}"
                del_ssl() {
                    service stunnel4 stop
                    apt-get remove stunnel4 -y
                    apt-get autoremove stunnel4 -y
                    apt-get purge stunnel4 -y
                    rm -rf /etc/stunnel/stunnel.conf
                    rm -rf /etc/default/stunnel4
                    rm -rf /etc/stunnel/stunnel.pem
                }
                echo ""
                fun_bar 'del_ssl'
                echo ""
                echo -e "${green}SSL TUNNEL SUCCESSFULLY REMOVED!${nc}"
                sleep 3
                clear
                inst_ssl
                ;;
            3)
                # User wants to return to the main menu
                echo -e "${red}Returning...${nc}"
                sleep 3
                clear
                show_CONNECTION_PROTOCLE_submenu
                ;;
            *)
                # Invalid option selected
                echo -e "${red}Invalid option!${nc}"
                sleep 3
                clear
                inst_ssl
                ;;
        esac
    else
        clear
        echo -e "${green}           SSL TUNNEL INSTALLER             ${nc}"
        echo ""
        echo -e "${RED} 1)${NC} => ${CYAN}INSTALL SSL TUNNEL STANDARD${nc}"
        echo -e "${RED} 2)${NC} => ${CYAN}COME BACK${nc}"
        echo ""
        echo -ne "${yellow}WHAT DO YOU WANT TO DO ?${nc} "
        read response
        echo ""
        if [[ "$response" = '1' ]]; then
            portssl='22'
        elif [[ "$response" = '2' ]]; then
            echo -e "${red}Returning...${nc}"
            sleep 3
            show_CONNECTION_PROTOCLE_submenu
        else
            echo ""
            echo -e "${red}Invalid option !${nc}"
            sleep 1
            inst_ssl
        fi
        echo ""
        echo -ne "${yellow}DO YOU WISH TO CONTINUE [y/n]:${nc} "
        read response
        [[ "$response" = 'y' ]] && {
            echo ""
            echo -ne "${yellow}WHICH PORT YOU WANT TO USE ?${nc} "
            read port
            [[ -z "$port" ]] && {
                echo ""
                echo -e "${red}Invalid port!${nc}"
                sleep 3
                clear
                inst_ssl
            }
            verif_ptrs $port
            echo -e "${green}INSTALLING SSL TUNNEL !${nc}"
            echo ""
            fun_bar 'apt-get update -y' 'apt-get install stunnel4 -y'
            echo -e "${green}CONFIGURING SSL TUNNEL !${nc}"
            echo ""
            ssl_conf() {
                echo -e "cert = /etc/stunnel/stunnel.pem\nclient = no\nsocket = a:SO_REUSEADDR=1\nsocket = l:TCP_NODELAY=1\nsocket = r:TCP_NODELAY=1\n\n[stunnel]\nconnect = 127.0.0.1:$portssl\naccept = ${port}" >/etc/stunnel/stunnel.conf
            }
				fun_bar 'ssl_conf'
				echo -e "${yellow}CREATING CERTIFICATE!${nc}"
				echo ""
				ssl_certif() {
					#crt='EC'
					#openssl genrsa -out key.pem 2048 >/dev/null 2>&1
					#(
					#echo $crt
					#echo $crt
					#echo $crt
					#echo $crt
					#echo $crt
					#echo $crt
					#echo $crt
					#) | openssl req -new -x509 -key key.pem -out cert.pem -days 1050 >/dev/null 2>&1
					#cat cert.pem key.pem >>/etc/stunnel/stunnel.pem
					#rm key.pem cert.pem >/dev/null 2>&1
					sed -i 's/ENABLED=0/ENABLED=1/g' /etc/default/stunnel4
                cd /etc/stunnel && wget https://raw.githubusercontent.com/opiran-club/opiran-panel/main/Modules/stunnel.pem && cd $HOME
            }
				fun_bar 'ssl_certif'
				echo -e "${green}STARTING SSL TUNNEL !${nc}"
				echo ""
				fun_finssl() {
					service stunnel4 restart
					service ssh restart
					/etc/init.d/stunnel4 restart
				}
				fun_bar 'fun_finssl' 'service stunnel4 restart'
				echo -e "${green}SSL TUNNEL SUCCESSFULLY INSTALLED !${nc} ${cyan}PORT:${nc} ${yellow}$port${nc}"
				sleep 3
				clear
				inst_ssl
			} || {
				echo -e "${red}Returning...${nc}"
				sleep 2
				clear
				show_CONNECTION_PROTOCLE_submenu
			}
		fi
	}
