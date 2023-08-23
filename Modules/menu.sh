#!/bin/bash

CYAN="\e[36m"
WHITE="\e[37m"
GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
NC="\e[0m"

fun_drop() {
		if netstat -nltp | grep 'dropbear' 1>/dev/null 2>/dev/null; then
			clear
			[[ $(netstat -nltp | grep -c 'dropbear') != '0' ]] && dpbr=$(netstat -nplt | grep 'dropbear' | awk -F ":" {'print $4'} | xargs) || sqdp="\033[1;31mINDISPONIVEL"
			if ps x | grep "limiter" | grep -v grep 1>/dev/null 2>/dev/null; then
				stats='${GREEN}✔✔${NC}'
			else
				stats='${RED}✗✗${NC}'
			fi
			echo -e "\E[44;1;37m              MANAGE DROPBEAR               \E[0m"
			echo -e "\n\033[1;33mPORT\033[1;37m => \033[1;32m$dpbr"
			echo ""
			echo -e "\033[1;31m[\033[1;36m1\033[1;31m] \033[1;37m \033[1;33mDROPBEAR LIMITER $stats\033[0m"
			echo -e "\033[1;31m[\033[1;36m2\033[1;31m] \033[1;37m \033[1;33mCHANGE DROPBEAR PORT\033[0m"
			echo -e "\033[1;31m[\033[1;36m3\033[1;31m] \033[1;37m \033[1;33mREMOVE DROPBEAR\033[0m"
			echo -e "\033[1;31m[\033[1;36m0\033[1;31m] \033[1;37m \033[1;33mCOME BACK\033[0m"
			echo ""
			echo -ne "\033[1;32mWHAT DO YOU WANT TO DO \033[1;33m?\033[1;37m "
			read resposta
			if [[ "$resposta" = '1' ]]; then
				clear
				if ps x | grep "limiter" | grep -v grep 1>/dev/null 2>/dev/null; then
					echo -e "\033[1;32mstopping the limiter... \033[0m"
					echo ""
					fun_stplimiter() {
						pidlimiter=$(ps x | grep "limiter" | awk -F "pts" {'print $1'})
						kill -9 $pidlimiter
						screen -wipe
					}
					fun_bar 'fun_stplimiter' 'sleep 2'
					echo -e "\n\033[1;31m LIMIT DISABLED \033[0m"
					sleep 3
					fun_drop
				else
					echo -e "\n\033[1;32mStarting the limiter... \033[0m"
					echo ""
					fun_bar 'screen -d -m -t limiter droplimiter' 'sleep 3'
					echo -e "\n\033[1;32m  LIMITER ENABLED \033[0m"
					sleep 3
					fun_drop
				fi
			elif [[ "$resposta" = '2' ]]; then
				echo ""
				echo -ne "\033[1;32mWHICH PORT YOU WANT TO USE \033[1;33m?\033[1;37m "
				read pt
				echo ""
				verif_ptrs $pt
				var1=$(grep 'DROPBEAR_PORT=' /etc/default/dropbear | cut -d'=' -f2)
				echo -e "\033[1;32mCHANGING DROPBEAR PORT!"
				sed -i "s/\b$var1\b/$pt/g" /etc/default/dropbear >/dev/null 2>&1
				echo ""
				fun_bar 'sleep 2'
				echo -e "\n\033[1;32mRESTARTING DROPBEAR!"
				echo ""
				fun_bar 'service dropbear restart' '/etc/init.d/dropbear restart'
				echo -e "\n\033[1;32mSUCCESSFULLY CHANGED PORT!"
				sleep 3
				clear
				return
			elif [[ "$resposta" = '3' ]]; then
				echo -e "\n\033[1;32mREMOVING THE DROPBEAR!\033[0m"
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
				echo -e "\n\033[1;32mSUCCESSFULLY REMOVED DROPBEAR !\033[0m"
				sleep 3
				clear
				return
			elif [[ "$resposta" = '0' ]]; then
				echo -e "\n\033[1;31mReturning...\033[0m"
				sleep 2
				return
			else
				echo -e "\n\033[1;31mInvalid option...\033[0m"
				sleep 2
				return
			fi
		else
			clear
			echo -e "\E[44;1;37m           DROPBEAR INSTALLER              \E[0m"
			echo -e "\n\033[1;33m INSTALL DROPBEAR !\033[0m\n"
			echo -ne "\033[1;32mDO YOU WISH TO CONTINUE \033[1;31m? \033[1;33m[y/n]:\033[1;37m "
			read resposta
			[[ "$resposta" = [Yy] ]] && {
				echo -e "\n\033[1;33mDEFINE A PORT FOR DROPBEAR !\033[0m\n"
				echo -ne "\033[1;32mWHICH PORT \033[1;33m?\033[1;37m "
				read porta
				[[ -z "$porta" ]] && {
					echo -e "\n\033[1;31mInvalid port!"
					sleep 3
					clear
					return
				}
				verif_ptrs $porta
				echo -e "\n\033[1;32mINSTALLING DROPBEAR ! \033[0m"
				echo ""
				fun_instdrop() {
					apt-get update -y
					apt-get install dropbear -y
				}
				fun_bar 'fun_instdrop'
				fun_ports() {
					sed -i 's/NO_START=1/NO_START=0/g' /etc/default/dropbear >/dev/null 2>&1
					sed -i "s/DROPBEAR_PORT=22/DROPBEAR_PORT=$porta/g" /etc/default/dropbear >/dev/null 2>&1
					sed -i 's/DROPBEAR_EXTRA_ARGS=/DROPBEAR_EXTRA_ARGS="-p 110"/g' /etc/default/dropbear >/dev/null 2>&1
				}
				echo ""
				echo -e "\033[1;32mSETTING PORT DROPBEAR!\033[0m"
				echo ""
				fun_bar 'fun_ports'
				grep -v "^PasswordAuthentication yes" /etc/ssh/sshd_config >/tmp/passlogin && mv /tmp/passlogin /etc/ssh/sshd_config
				echo "PasswordAuthentication yes" >>/etc/ssh/sshd_config
				grep -v "^PermitTunnel yes" /etc/ssh/sshd_config >/tmp/ssh && mv /tmp/ssh /etc/ssh/sshd_config
				echo "PermitTunnel yes" >>/etc/ssh/sshd_config
				echo ""
				echo -e "\033[1;32mFINISHING INSTALLATION !\033[0m"
				echo ""
				fun_ondrop() {
					service dropbear start
					/etc/init.d/dropbear restart
				}
				fun_bar 'fun_ondrop' 'sleep 1'
				echo -e "\n\033[1;32mINSTALLATION COMPLETED \033[1;33mPORT: \033[1;37m$porta\033[0m"
				[[ $(grep -c "/bin/false" /etc/shells) = '0' ]] && echo "/bin/false" >>/etc/shells
				sleep 2
				clear
				return
			} || {
				echo""
				echo -e "\033[1;31mReturning...\033[0m"
				sleep 3
				clear
				return
			}
		fi
	}
 
# Function to execute the selected script
execute_script() {
    local script_name="$1"
    if [ -f "/bin/$script_name" ]; then
        bash "/bin/$script_name"
    else
        echo -e "Error: Script not found!" "${RED}"
    fi
}

# Function to get the total number of users
get_total_users() {
  total_users=$(awk -F: '$3>=1000 {print $1}' /etc/passwd | grep -v nobody | wc -l)
  echo "$total_users"
}

# Function to get the number of online users
get_online_users() {
  online_users=$(bash /bin/monitor_online.sh | grep -o "✔" | wc -l)
  echo "$online_users"
}

# Function to get the number of expired users
get_expired_users() {
  expired_users=$(awk -F: '$3>=1000 {print $1}' /etc/passwd | grep -v nobody | while read _user; do
    if is_account_expired "$_user"; then
      echo "$_user"
    fi
  done | wc -l)
  echo "$expired_users"
}

# Function to display the main menu
show_menu() {

  tot=$(get_total_users)
  onli=$(get_online_users)
  exp=$(get_expired_users)
  
        is_script_running() {
            local script_name="$1"
            if ps aux | grep -q "/bin/$script_name"; then
                echo -e "${GREEN}✔✔${NC}"
            else
                echo -e "${RED}✗✗${NC}"
            fi
        }
clear
echo ""
echo -e "${GREEN}────────────────────────────────────────────────────────${NC}"
echo ""
echo -e "                  ${WHITE}OPIran Panel${NC}"
echo ""
echo -e "${GREEN}TG-Group @OPIranCluB${NC}"
echo -e "${RED}────────────────────────────────────────────────────────${NC}"
echo ""
printf "${GREEN}TOTAL USER ${YELLOW}  %s   ${GREEN}ONLINE USER ${YELLOW}   %s   ${GREEN}EXPIRED USER ${YELLOW}  %s\n" "$tot" "$onli" "$exp"
echo ""
echo -e "${YELLOW}────────────────────${NC}   SSH Menu   ${YELLOW}───────────────────────${NC}"
echo ""
echo -e "${RED} 1)${NC} => ${CYAN}CREATE ACCOUNTS ${NC}"
echo -e "${RED} 2)${NC} => ${CYAN}EDIT SSH ACCOUNTS ${NC}"
echo -e "${RED} 3)${NC} => ${CYAN}SSH ACCOUNTS DETAILS ${NC}"
echo -e "${RED} 4)${NC} => ${CYAN}REMOVE EXPIRED ACCOUNTS (AUTO) ${NC}"
echo -e "${RED} 5)${NC} => ${CYAN}ADD DOMAIN ${NC}"
echo -e "${RED} 6)${NC} => ${CYAN}BADVPN (UDPGW)${NC}"
echo -e "${RED} 7)${NC} => ${CYAN}BACKUP & RESTORE${NC}"
echo -e "${RED} 8)${NC} => ${CYAN}CONNECTION PROTOCLE MENU${NC}"
echo -e "${RED} 9)${NC} => ${CYAN}MORE OPTION MENU${NC}"
echo ""
echo -e "${YELLOW}───────────────────────${NC} V2ray Menu ${YELLOW}───────────────────────${NC}"
echo ""
echo -e "${RED} 10)${NC} => ${CYAN}V2RAY panels${NC}"
echo -e "${RED} 11)${NC} => ${CYAN}REALITY panels${NC}"
echo -e "${RED} 12)${NC} => ${CYAN}SSL TUNNEL (STUNNEL) ${NC}"
echo ""
echo -e "${YELLOW}───────────────────────${NC} MONITORING ${YELLOW}───────────────────────${NC}"
echo ""
echo -e "${RED} 13)${NC} => ${CYAN}Dropbear Limiter & Monitoring${NC} $(is_script_running limiter_dropbear.sh) "
echo -e "${RED} 14)${NC} => ${CYAN}SSH Limiter & Monitoring ${NC} $(is_script_running limiter_ssh.sh) "
echo -e "${RED} 15)${NC} => ${CYAN}Online Users Monitoring ${NC}"
echo ""
echo -e "${YELLOW}───────────────────────${NC}    OTHER   ${YELLOW}───────────────────────${NC}"
echo ""
echo -e "${RED} 16)${NC} => ${CYAN}UPDATE THE SCRIPT ${YELLOW}(No need backup) ${NC}"
echo -e "${RED}  U)${NC} => ${CYAN}UNINSTALL OPIRAN PANEL${NC}"  
echo -e "${RED}  E)${NC} => ${CYAN}Exit${NC}"
echo ""
echo -e "${RED}────────────────────────────────────────────────────────${NC}"
echo ""
echo -e "${GREEN}      How Can I Help You?? ${YELLOW}"

}

# Function to display the V2RAY panels sub-menu
show_V2RAY_panels_submenu() {
    clear
    echo -e "${GREEN}────────────────────────────────────────────────────────${NC}"
    echo -e "         ${WHITE}───── V2ray Panels  ─────${NC}"
    echo -e "${RED}────────────────────────────────────────────────────────${NC}"
    echo ""
    echo -e "${RED} 1)${NC} => ${CYAN}hossein assadi's x-ui${NC}"
    echo -e "${RED} 2)${NC} => ${CYAN}vaxilu (original)${NC}"
    echo -e "${RED} 3)${NC} => ${CYAN}hiddify${NC}"
    echo -e "${RED} 4)${NC} => ${CYAN}alireza0 x-ui${NC}"
    echo -e "${RED} 5)${NC} => ${CYAN}3x-ui (MHSanaei)${NC}"
    echo -e "${RED} 6)${NC} => ${CYAN}kafka x-ui${NC}"
    echo -e "${RED} 7)${NC} => ${CYAN}alireza0 x-ui${NC}"
    echo ""
    echo -e "${YELLOW}────────────────────────────────────────────────────────${NC}"
    echo ""
    echo -e "${RED} M)${NC} => ${CYAN}Main Menu${NC}"
    echo ""
    echo -e "${RED}────────────────────────────────────────────────────────${NC}"
    echo ""
    read -p "Enter option number: " choice

    case $choice in
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
            M|m) return ;;
            E|e) echo -e "${RED}Exiting...${NC}"; exit ;;
            *) echo -e "${RED}Invalid option...${NC}" ; sleep 2 ;;
    esac
}

# Function to display the CREATE USER sub-menu
show_SSH_ACCOUNTS_MENU_submenu() {
    clear
    echo -e "${GREEN}────────────────────────────────────────────────────────${NC}"
    echo -e "        ${WHITE}───── CREATE SSH Account  ─────${NC}"
    echo -e "${RED}────────────────────────────────────────────────────────${NC}"
    echo ""
    echo -e "${RED} 1)${NC} => ${CYAN}Create Single Account${NC}"
    echo -e "${RED} 2)${NC} => ${CYAN}Create Bulk Accounts${NC}"
    echo -e "${RED} 3)${NC} => ${CYAN}Create Test/(Hourly) Account ${NC}"
    echo -e "${RED} 4)${NC} => ${CYAN}Remove Accounts${NC}"
    echo ""
    echo -e "${YELLOW}────────────────────────────────────────────────────────${NC}"
    echo ""
    echo -e "${RED} M)${NC} => ${CYAN}Main Menu${NC}"
    echo -e "${RED} E)${NC} => ${CYAN}Exit ${NC}"
    echo ""
    echo -e "${RED}────────────────────────────────────────────────────────${NC}"
    echo ""
    echo -e "${GREEN}Please enter your choice:${YELLOW}"
    read -r choice

        case "$choice" in
            1) execute_script "create_user.sh" ;;
            2) execute_script "create_bulkuser.sh" ;;
            3) execute_script "create_test.sh" ;;
            4) execute_script "user_remover.sh" ;;
            M|m) return ;;
            E|e) echo -e "${RED}Exiting...${NC}"; exit ;;
            *) echo -e "${RED}Invalid option...${NC}" ; sleep 2 ;;
    esac
}

# Function to display MENU2 sub-menu
show_MORE_OPTION_MENU_submenu() {
    clear

    echo -e "${GREEN}────────────────────────────────────────────────────────${NC}"
    echo -e "         ${WHITE}───── MORE OPTION  ─────${NC}"
    echo -e "${RED}────────────────────────────────────────────────────────${NC}"
    echo ""
    echo -e "${RED} 1)${NC} => ${CYAN}FIREWALL & TORRENT${NC}"
    echo -e "${RED} 2)${NC} => ${CYAN}BLOCK IP (COUNTRY)${NC}"
    echo -e "${RED} 3)${NC} => ${CYAN}TELEGRAM BOT (SOON)${NC}"
    echo -e "${RED} 4)${NC} => ${CYAN}ADD BANNER${NC}"
    echo -e "${RED} 5)${NC} => ${CYAN}CF WARP${NC}"
    echo -e "${RED} 6)${NC} => ${CYAN}SPEEDTEST${NC}"
    echo -e "${RED} 7)${NC} => ${CYAN}VPS-OPTIMIZER${NC}"
    echo -e "${RED} 8)${NC} => ${CYAN}MTProto Proxy${NC}"
    echo -e "${RED} 9)${NC} => ${CYAN}Google Recaptua Fixer${NC}"
    echo ""
    echo -e "${YELLOW}────────────────────────────────────────────────────────${NC}"
    echo ""
    echo -e "${RED} M)${NC} => ${CYAN}Main Menu${NC}"
    echo -e "${RED} E)${NC} => ${CYAN}Exit${NC}"
    echo ""
    echo -e "${RED}────────────────────────────────────────────────────────${NC}"
    echo ""
    echo -e "${GREEN}Please enter your choice:${YELLOW}"
    read -r choice

        case "$choice" in
            1) execute_script "fandt.sh" ;;
            2) execute_script "block_ip.sh" ;;
            3) execute_script "telegram_bot.sh" ;;
            4) execute_script "add_banner.sh" ;;
            5) execute_script "cfwarp.sh" ;;
            6) execute_script "speedtest.sh" ;;
            7) execute_script "optimizer.sh" ;;
            8)
            # Prompt user for input
            echo "Please enter the following information:"
            read -p "Port number (default is 443): " port
            echo "for secret you you can use http://seriyps.ru/mtpgen.html "
            read -p "Secret key (should be a string of 32 hexadecimal characters): " secret_key
            echo "to get the server tag you should use telegram bot https://t.me/MTProxybot "
            read -p "Server tag (should be a string of 32 hexadecimal characters): " server_tag
            read -p "List of authentication methods - place empty for default - (should be a comma-separated list): " auth_methods
            read -p "MTProto domain (should be a valid domain name): " mtproto_domain
            # Set default values if user input is empty
            port=${port:-443}
            auth_methods=${auth_methods:-"dd,-a tls"}
            # Download and run MTProto installation script
            curl -L -o mtp_install.sh https://git.io/fj5ru && \
            bash mtp_install.sh -p $port -s $secret_key -t $server_tag -a $auth_methods -d $mtproto_domain
            echo -e "Press ${RED}ENTER${NC} to continue"
            read -s -n 1
            ;;
            9)
            echo -e "${GREEN}Fixing Google Recapcha...${NC}"
            echo ""
            curl -O https://raw.githubusercontent.com/jinwyp/one_click_script/master/install_kernel.sh && chmod +x ./install_kernel.sh && ./install_kernel.sh
            echo ""
            echo -e "Press ${RED}ENTER${NC} to continue"
            read -s -n 1
            ;;
            M|m) return ;;
            E|e) echo -e "${RED}Exiting...${NC}"; exit ;;
            *) echo -e "${RED}Invalid option...${NC}" ; sleep 2 ;;
    esac
}

# Function to display the EDIT USER sub-menu
show_EDIT_USER_MENU_submenu() {
    clear

    echo -e "${GREEN}────────────────────────────────────────────────────────${NC}"
    echo -e "          ${WHITE}───── EDIT USER  ─────${NC}"
    echo -e "${RED}────────────────────────────────────────────────────────${NC}"
    echo ""
    echo -e "${RED} 1)${NC} => ${CYAN}Modify User Limit ${NC}"
    echo -e "${RED} 2)${NC} => ${CYAN}Modify User Password ${NC}"
    echo -e "${RED} 3)${NC} => ${CYAN}Modify Expiration Date ${NC}"
    echo ""
    echo -e "${YELLOW}────────────────────────────────────────────────────────${NC}"
    echo ""
    echo -e "${RED} M)${NC} => ${CYAN}Main Menu${NC}"
    echo -e "${RED} E)${NC} => ${CYAN}Exit${NC}"
    echo ""
    echo -e "${RED}────────────────────────────────────────────────────────${NC}"
    echo ""
    echo -e "${GREEN}Please enter your choice:${YELLOW}"
    read -r choice

        case "$choice" in
            1) execute_script "modify_limit.sh" ;;
            2) execute_script "modify_password.sh" ;;
            3) execute_script "modify_expiry&monitor.sh" ;;
            M|m) return ;;
            E|e) echo -e "${RED}Exiting...${NC}"; exit ;;
            *) echo -e "${RED}Invalid option...${NC}" ; sleep 2 ;;
    esac
}

# Function to display CONNECTION PROTOCLE sub-menu
show_CONNECTION_PROTOCLE_MENU_submenu() {
[[ "$(netstat -tlpn | grep 'dropbear' | wc -l)" != '0' ]] && { $(netstat -nplt | grep 'dropbear' | awk -F ":" '{print $4}' | xargs)
    sts2="${GREEN}✔✔${NC}"
} || {
    sts2="${RED}✗✗${NC}"
}
    clear
    echo -e "${GREEN}────────────────────────────────────────────────────────${NC}"
    echo -e "        ${WHITE}───── CONNECTION PROTOCLE  ─────${NC}"
    echo -e "${RED}────────────────────────────────────────────────────────${NC}"
    echo ""
    echo -e "${RED} 1)${NC} => ${CYAN}OpenSSH${NC}"
    echo -e "${RED} 2)${NC} => ${CYAN}Dropbear $sts2 ${NC}"
    echo -e "${RED} 3)${NC} => ${CYAN}Squid Proxy${NC}"
    echo -e "${RED} 4)${NC} => ${CYAN}WEBSOCKET-SSH Cloudflare${NC}"
    echo -e "${RED} 5)${NC} => ${CYAN}CISCO Anyconnect${NC}"
    echo -e "${RED} 6)${NC} => ${CYAN}Wiregaurd${NC}"
    echo -e "${RED} 7)${NC} => ${CYAN}IPSEC VPN${NC}"
    echo ""
    echo -e "${YELLOW}────────────────────${NC} TUNNELING  ${YELLOW}───────────────────────${NC}"
    echo ""
    echo -e "${RED} 8)${NC} => ${CYAN}Dekodemodoor Tunnels${NC}"
    echo -e "${RED} 9)${NC} => ${CYAN}IPtables Tunnels${NC}"
    echo -e "${RED}10)${NC} => ${CYAN}Chisel Tunnels${NC}"
    echo -e "${RED}11)${NC} => ${CYAN}SSL Tunnels${NC}"
    echo ""
    echo -e "${YELLOW}────────────────────────────────────────────────────────${NC}"
    echo ""
    echo -e "${RED} M)${NC} => ${CYAN}Main Menu${NC}"
    echo -e "${RED} E)${NC} => ${CYAN}Exit${NC}"
    echo ""
    echo -e "${YELLOW}────────────────────────────────────────────────────────${NC}"
    echo ""
    echo -e "${GREEN}Please enter your choice:${YELLOW}"
    read -r choice

        case "$choice" in
            1) execute_script "openssh.sh" ;;
            2) 
            fun_drop
            ;;
            3) execute_script "squid.sh" ;;
            4) execute_script "wsproxy.sh" ;;
            5) execute_script "cisco.sh" ;;
            6) execute_script "wiregaurd.sh" ;;
            7) execute_script "ipsec.sh" ;;
            8) execute_script "deko.sh" ;;
            9) execute_script "iptable.sh" ;;
            10) execute_script "chisel.sh" ;;
            11) execute_script "ssl.sh" ;;
            M|m) return ;;
            E|e) echo -e "${RED}Exiting...${NC}"; exit ;;
            *) echo -e "${RED}Invalid option...${NC}" ; sleep 2 ;;
    esac
}

# Main script execution
while true; do
    show_menu

    read -r choice

    case "$choice" in
        1) show_SSH_ACCOUNTS_MENU_submenu ;;
        2) show_EDIT_USER_MENU_submenu ;;
        3) execute_script "info_users.sh" ;;
        4) execute_script "expired.sh" ;;
        5) execute_script "add_domain.sh" ;;
        6) execute_script "badvpn.sh" ;;
        7) execute_script "backup_restore.sh" ;;
        8) show_CONNECTION_PROTOCLE_MENU_submenu ;;
        9) show_MORE_OPTION_MENU_submenu ;;
       10) show_V2RAY_panels_submenu ;;
       11) execute_script "reality.sh" ;;
       12) execute_script "ssl.sh" ;;
       13) execute_script "limiter_dropbear.sh" ;;
       14) execute_script "limiter_ssh.sh" ;;
       15) execute_script "monitor_online.sh" ;;
       16)
       clear
           echo -e "${YELLOW}AFTER PRESSING ${RED}ENTER${NC} ${YELLOW}UPDATING THE PANEL WILL BE START,SO PLEASE BE PATIENT${NC}"
           read -s -n 1
           apt update && apt upgrade -y && bash -c "$(curl -fsSL https://raw.githubusercontent.com/opiran-club/opiran-panel/main/install.sh)" && source ~/.bashrc
           break
        ;;
        U|u) execute_script "uninstall.sh" ;;
        E|e) echo -e "${RED}Exiting...${NC}"; exit ;;
        *) echo -e "${RED}Invalid option...${NC}" ; sleep 2 ;;
    esac
done
