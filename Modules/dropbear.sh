#!/bin/bash

CYAN="\e[36m"
GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
CYAN="\e[36m"
NC="\e[0m"

fun_drop() {
		if netstat -nltp | grep 'dropbear' 1>/dev/null 2>/dev/null; then
			clear
			[[ $(netstat -nltp | grep -c 'dropbear') != '0' ]] && dpbr=$(netstat -nplt | grep 'dropbear' | awk -F ":" {'print $4'} | xargs) || sqdp="\033[1;31mINDISPONIVEL"
			if ps x | grep "limiter" | grep -v grep 1>/dev/null 2>/dev/null; then
				stats='\033[1;32m✅ '
			else
				stats='\033[1;31m❌ '
			fi
            echo -e "${green}────────────────────────────────────────────────────────${NC}"
            echo -e "        ${white}───── MANAGE DROPBEAR  ─────${NC}"
            echo -e "${RED}────────────────────────────────────────────────────────${NC}"
            echo ""
			echo -e "${CYAN}DROPBEAR PORT =>${NC} ${yellow}$dpbr${NC}"
			echo ""
			echo -e "${RED} 1)${NC} => ${CYAN}DROPBEAR LIMITER $stats${NC}"
			echo -e "${RED} 2)${NC} => ${CYAN}CHANGE DROPBEAR PORT${NC}"
			echo -e "${RED} 3)${NC} => ${CYAN}REMOVE DROPBEAR${NC}"
			echo -e "${RED} 4)${NC} => ${CYAN}Main menu${NC}"
			echo ""
            echo -e "${RED}────────────────────────────────────────────────────────${NC}"
            echo ""
			echo -ne "${yellow}WHAT DO YOU WANT TO DO ?${NC}${CYAN}${NC} "
			read -r response
			case "$response" in
            1)
				clear
				if ps x | grep "limiter" | grep -v grep 1>/dev/null 2>/dev/null; then
					echo -e "${yellow}stopping the limiter... ${NC}"
					echo ""
					fun_stplimiter() {
						pidlimiter=$(ps x | grep "limiter" | awk -F "pts" {'print $1'})
						kill -9 $pidlimiter
						screen -wipe
					}
					fun_bar 'fun_stplimiter' 'sleep 2'
					echo -e "${yellow} LIMIT DISABLED ${NC}"
					sleep 3
					fun_drop
				else
					echo -e "${yellow}Starting the limiter... ${NC}"
					echo ""
					fun_bar 'screen -d -m -t limiter droplimiter' 'sleep 3'
					echo -e "${yellow}  LIMITER ENABLED ${NC}"
					sleep 3
					fun_drop
				fi
			 ;;
            2)
				echo ""
				echo -ne "${yellow}WHICH PORT YOU WANT TO USE ?${NC}${CYAN}${NC} "
				read -r pt
				echo ""
				verif_ptrs $pt
				var1=$(grep 'DROPBEAR_PORT=' /etc/default/dropbear | cut -d'=' -f2)
				echo -e "\033[1;32mCHANGING DROPBEAR PORT!"
				sed -i "s/\b$var1\b/$pt/g" /etc/default/dropbear >/dev/null 2>&1
				echo ""
				fun_bar 'sleep 2'
				echo -e "${yellow}RESTARTING DROPBEAR!${NC}"
				echo ""
				fun_bar 'service dropbear restart' '/etc/init.d/dropbear restart'
				echo -e "${yellow}SUCCESSFULLY CHANGED PORT!${NC}"
				sleep 3
				clear
				fun_drop
			 ;;
            3)
				echo -e "${yellow}REMOVING THE DROPBEAR!${NC}"
				echo ""
				fun_dropunistall() {
					service dropbear stop && /etc/init.d/dropbear stop
					apt-get autoremove dropbear -y
					apt-get remove dropbear-run -y
					apt-get remove dropbear -y
					apt-get purge dropbear -y
					rm -rf /etc/default/dropbear
				}
				fun_bar 'fun_dropunistall'
				echo -e "${yellow}SUCCESSFULLY REMOVED DROPBEAR !${NC}"
				sleep 3
				clear
				fun_drop
			 ;;
            4)
				echo -e "${red}Returning...${NC}"
				sleep 2
				show_CONNECTION_PROTOCLE_submenu
			 ;;
            *)
				echo -e "${red}Invalid option...${NC}"
				sleep 2
				fun_drop
			;;
        esac
    else
			clear
            echo -e "${green}────────────────────────────────────────────────────────${NC}"
            echo -e "        ${white}───── DROPBEAR INSTALLER  ─────${NC}"
            echo -e "${RED}────────────────────────────────────────────────────────${NC}"
            echo ""
			echo -ne "${yellow}DO YOU WISH TO CONTINUE ?${NC} ${green}[y/n]:${NC} "
			read -r response
			if [[ "$response" = 'y' ]]; then
                echo -e "${cyan}DEFINE A PORT FOR DROPBEAR !${NC}"
                echo -ne "${yellow}WHICH PORT ?${NC} "
                read -r port
                [[ -z "$port" ]] && {
                    echo -e "${red}Invalid port!${NC}"
                    sleep 3
                    clear
                    fun_drop
                }
                verif_ptrs "$port"
                echo -e "${yellow}INSTALLING DROPBEAR ! ${NC}"
                echo ""
                fun_instdrop() {
                    apt-get update -y
                    apt-get install dropbear -y
                }
                fun_bar 'fun_instdrop'
                fun_ports() {
                    sed -i 's/NO_START=1/NO_START=0/g' /etc/default/dropbear >/dev/null 2>&1
                    sed -i "s/DROPBEAR_PORT=22/DROPBEAR_PORT=$port/g" /etc/default/dropbear >/dev/null 2>&1
                    sed -i 's/DROPBEAR_EXTRA_ARGS=/DROPBEAR_EXTRA_ARGS="-p 110"/g' /etc/default/dropbear >/dev/null 2>&1
                }
                echo ""
                echo -e "${yellow}SETTING PORT DROPBEAR!${NC}"
                echo ""
                fun_bar 'fun_ports'
                grep -v "^PasswordAuthentication yes" /etc/ssh/sshd_config >/tmp/passlogin && mv /tmp/passlogin /etc/ssh/sshd_config
                echo "PasswordAuthentication yes" >>/etc/ssh/sshd_config
                grep -v "^PermitTunnel yes" /etc/ssh/sshd_config >/tmp/ssh && mv /tmp/ssh /etc/ssh/sshd_config
                echo "PermitTunnel yes" >>/etc/ssh/sshd_config
                echo ""
                echo -e "${yellow}FINISHING INSTALLATION !${NC}"
                echo ""
                fun_ondrop() {
                    service dropbear start
                    /etc/init.d/dropbear restart
                }
                fun_bar 'fun_ondrop' 'sleep 1'
                echo -e "${green}INSTALLATION COMPLETED${NC} ${cyan}PORT:${NC} ${yellow}$port${NC}"
                [[ $(grep -c "/bin/false" /etc/shells) = '0' ]] && echo "/bin/false" >>/etc/shells
                sleep 2
                clear
                fun_drop
            else
                echo ""
                echo -e "${red}Returning...${NC}"
                sleep 3
                clear
                show_CONNECTION_PROTOCLE_submenu
            fi
            ;
            else
            echo ""
            echo -e "${red}Returning...${NC}"
            sleep 3
            clear
            show_CONNECTION_PROTOCLE_submenu
        fi
    fi
}
    
