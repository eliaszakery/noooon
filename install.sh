#!/bin/bash

CYAN="\e[36m"
MAGENTA="\e[35m"
BLUE="\e[34m"
GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
WHITE="\e[37m"
NC="\e[0m"

# Remove existing install.sh in root if it exists
check_install() {
if [ -f "/root/install.sh" ]; then
    echo -e "${YELLOW}Removing existing install.sh in root...${NC}"
    rm /root/install.sh > /dev/null 2>&1
fi
}

# Function to check run as root
check_root() {
if [ "$EUID" -ne 0 ]
then echo "${RED}Please run as root${NC}"
exit
fi
}

# Function to display a fancier progress bar
display_fancy_progress() {
    local duration=$1
    local sleep_interval=0.1
    local progress=0
    local bar_length=18

    while [ $progress -lt $duration ]; do
        echo -ne "\r[${YELLOW}"
        for ((i = 0; i < bar_length; i++)); do
            if [ $i -lt $((progress * bar_length / duration)) ]; then
                echo -ne "▓"  # Use the block element character
            else
                echo -ne "░"  # Use another block element character for the empty space
            fi
        done
        echo -ne "${RED}] ${progress}%"
        progress=$((progress + 1))
        sleep $sleep_interval
    done
    echo -ne "\r[${YELLOW}"
    for ((i = 0; i < bar_length; i++)); do
        echo -ne "▓"  # Use the block element character
    done
    echo -ne "${RED}] ${progress}%"
    echo
}


# Function to change the package repository source list
change_source_list() {
    if [ -f "/etc/os-release" ]; then
        source /etc/os-release
        case "$ID" in
            debian|ubuntu)
                echo -e "${CYAN}Updating package repository source list for $ID...${NC}"
                # Add your custom source list entries here
                if [ "$ID" == "debian" ]; then
                    echo "deb http://archive.debian.org/debian/ stretch main contrib non-free" > /etc/apt/sources.list
                    echo "deb http://archive.debian.org/debian/ stretch-proposed-updates main contrib non-free" >> /etc/apt/sources.list
                    echo "deb http://archive.debian.org/debian-security stretch/updates main contrib non-free" >> /etc/apt/sources.list
                elif [ "$ID" == "ubuntu" ]; then 
                    echo "deb  http://archive.ubuntu.com/ubuntu/ jammy main restricted" > /etc/apt/sources.list
                    echo "deb  http://archive.ubuntu.com/ubuntu/ jammy-updates main restricted" >> /etc/apt/sources.list
                    echo "deb  http://archive.ubuntu.com/ubuntu/ jammy universe" >> /etc/apt/sources.list
                    echo "deb  http://archive.ubuntu.com/ubuntu/ jammy-updates universe" >> /etc/apt/sources.list
                    echo "deb  http://archive.ubuntu.com/ubuntu/ jammy multiverse" >> /etc/apt/sources.list
                    echo "deb  http://archive.ubuntu.com/ubuntu/ jammy-updates multiverse" >> /etc/apt/sources.list
                    echo "deb  http://archive.ubuntu.com/ubuntu/ jammy-backports main restricted universe multiverse" >> /etc/apt/sources.list
                    echo "deb  http://archive.ubuntu.com/ubuntu/ jammy-security main restricted" >> /etc/apt/sources.list
                    echo "deb  http://archive.ubuntu.com/ubuntu/ jammy-security universe" >> /etc/apt/sources.list
                    echo "deb  http://archive.ubuntu.com/ubuntu/ jammy-security multiverse" >> /etc/apt/sources.list
                fi
                apt-get update
                echo -e "${GREEN}Package repository source list updated for $ID.${NC}"
                ;;
            *)
                echo -e "${RED}Unsupported operating system: $ID.${NC}"
                ;;
        esac
    else
        echo -e "${RED}/etc/os-release not found. Unable to determine operating system.${NC}"
    fi
}

# Function to install required packages
install_dependencies() {
    apt-get update -y > /dev/null 2>&1
    _program=("bc" "apache2" "cron" "screen" "nano" "unzip" "lsof" "netstat" "net-tools" "dos2unix" "nload" "jq" "curl" "figlet" "python3" "python-pip")
    for _prog in ${_program[@]}; do
        apt install $_prog -y > /dev/null 2>&1
    done
}

# Function to create or use an existing user database
create_user_database() {
    if [ -f "$HOME/usuarios.db" ] || [ -f "$HOME/users.db" ]; then
        if [ -f "$HOME/usuarios.db" ]; then
            echo -e "${RED}User Database 'DRAGON VPS' Found!${NC}"
            echo -e "${CYAN}Do you want to transfer to OPIran Panel? [Y/N]${NC}"
            
            while true; do
                read -p "Your choice [Y/N]: " -e -i Y optiondb
                
                case "$optiondb" in
                    [Yy])
                        echo -e "${GREEN}Copying 'usuarios.db' to 'users.db'...${NC}"
                        cp "$HOME/usuarios.db" "$HOME/users.db" > /dev/null 2>&1
                        cp -r "$HOME/etc/VPSManager/senha" "$HOME/etc/OPIranPanel/password" > /dev/null 2>&1
                        echo -e "${GREEN}transfer to OPIran Panel successfully.${NC}"
                        break
                        ;;
                    [Nn])
                        echo -e "${GREEN}Keeping 'usuarios.db' as it is.${NC}"
                        break
                        ;;
                    *)
                        echo -e "${RED}Invalid input. Please enter Y or N.${NC}"
                        ;;
                esac
            done
        else
            echo -e "${RED}User Database 'OPIran Panel' Found!${NC}"
            echo -e "${CYAN}Do you want to keep the database? [Y/N]${NC}"
            while true; do
                read -p "Your choice [Y/N]: " -e -i Y optiondb
                case "$optiondb" in
                    [Yy])
                        break
                        ;;
                    [Nn])
                        awk -F : '$3 >= 500 { print $1 " 1" }' /etc/passwd | grep -v '^nobody' > "$HOME/users.db" > /dev/null 2>&1
                        echo -e "${GREEN}New database 'users.db' created successfully.${NC}"
                        break
                        ;;
                    *)
                        echo -e "${RED}Invalid input. Please enter Y or N.${NC}"
                        ;;
                esac
            done
        fi
    else
        echo -e "${GREEN}Creating a new database...${NC}"
        awk -F : '$3 >= 500 { print $1 " 1" }' /etc/passwd | grep -v '^nobody' > "$HOME/users.db" > /dev/null 2>&1
        echo -e "${GREEN}New database 'users.db' created successfully.${NC}"
    fi
}

# Function to set up the "dibah" command
setup_dibah_command() {
    
    # Check if the "menu" alias already exists in .bashrc
    if grep -q "alias menu=" ~/.bashrc; then
        echo -e "${RED}Menu alias Found!${NC}"
        echo -e "${CYAN}The 'menu' alias already exists. Do you want to overwrite it? [Y/N]${NC}"

        while true; do
            read -p "Your choice [Y/N]: " -e -i Y option_alias
            
            case "$option_alias" in
                [Yy])
                    # Update the "menu" alias
                    sed -i '/alias menu=/d' ~/.bashrc > /dev/null 2>&1
                    echo "alias menu='bash /usr/bin/menu.sh'" >> ~/.bashrc
		    sleep 0.5
		    source ~/.bashrc > /dev/null 2>&1
                    echo -e "${GREEN}'menu' alias updated.${NC}"
                    return
                    ;;
                [Nn])
                    echo -e "${GREEN}Keeping the existing 'menu' alias.${NC}"
                    break
                    ;;
                *)
                    echo -e "${RED}Invalid input. Please enter 1 or 2.${NC}"
                    ;;
            esac
        done
    else
        # Alias does not exist, add it
        echo "alias menu='bash /usr/bin/menu.sh'" >> ~/.bashrc
	source ~/.bashrc > /dev/null 2>&1
    fi
}

# Function to ask the user to select a timezone
ask_timezone() {
    echo -e "${YELLOW}Select your timezone:${NC}"
    echo -e "              ${RED}1)${NC}  ${BLUE}America/New_York${NC}"
    echo -e "              ${RED}2)${NC}  ${BLUE}Europe/London${NC}"
    echo -e "              ${RED}3)${NC}  ${BLUE}Asia/Iran${NC}"
    
    while true; do
        read -p "Your choice [1/2/3]: " -e -i 1 timezone_choice
        
        case "$timezone_choice" in
            1)
                selected_timezone="America/New_York"
                break
                ;;
            2)
                selected_timezone="Europe/London"
                break
                ;;
            3)
                selected_timezone="Asia/Tehran"
                break
                ;;
            
            *)
                echo -e "${RED}Invalid input. Please enter a valid option.${NC}"
                ;;
        esac
    done
    
    echo "$selected_timezone" > /etc/timezone
    ln -fs "/usr/share/zoneinfo/$selected_timezone" /etc/localtime >/dev/null 2>&1
    dpkg-reconfigure --frontend noninteractive tzdata >/dev/null 2>&1
    echo -e "${GREEN}Timezone set to $selected_timezone.${NC}"
}

# Function to ask the user for IP and IP6 addresses
ask_ip_addresses() {
    IP=$(wget -qO- ipv4.icanhazip.com > /dev/null 2>&1)
    IP6=$(curl -6 ifconfig.co > /dev/null 2>&1)

    echo -e "${YELLOW}Current IPv4 address is${NC} ${RED}$IP${NC}"
    read -p "Do you want to change it? [Y/N]: " -e -i N change_ip
    if [[ $change_ip =~ ^[Yy]$ ]]; then
        read -p "Enter the new IPv4 address: " user_ip
        echo -e "${GREEN}Setting IPv4 address to $user_ip...${NC}"
        echo "$user_ip" >/etc/IP
        echo -e "${GREEN}IPv4 address set to $user_ip.${NC}"
    fi

    if [ -n "$IP6" ]; then
        echo -e "${YELLOW}Current IPv6 address is${NC} ${RED}$IP6${NC}"
        read -p "Do you want to change it? [Y/N]: " -e -i N change_ip6
        if [[ $change_ip6 =~ ^[Yy]$ ]]; then
            read -p "Enter the new IPv6 address: " user_ip6
            echo -e "${GREEN}Setting IPv6 address to $user_ip6...${NC}"
            echo "$user_ip6" >/etc/IP6
            echo -e "${GREEN}IPv6 address set to $user_ip6.${NC}"
        fi
    else
        echo -e "${RED}IPv6 address is not available on this server.${NC}"
    fi
}

# Downloading and configuring additional scripts from GitHub
_mdls=("limiter_dropbear.sh" "limiter_ssh.sh" "add_banner.sh" "wsproxy.sh" "add_domain.sh" "backup_restore.sh" "badvpn.sh" "cfwarp.sh" "create_bulkuser.sh" "create_test.sh" "create_user.sh" "expired.sh" "fandt.sh" "info_users.sh" "ip-block.sh" "monitor_online.sh" "menu.sh" "modify_expiry&monitor.sh" "modify_limit.sh" "modify_password.sh" "optimizer.sh" "speedtest.sh" "traffic.sh" "uninstall.sh" "user_remover.sh" "chisel.sh" "dropbear.sh" "ipsec.sh" "iptable.sh" "openssh.sh" "reality.sh" "ssl.sh" "v2panel.sh" "wiregaurd.sh" "wsproxy.py")

# Function to download and configure scripts with a spinner
download_and_configure_scripts() {

    for _arq in "${_mdls[@]}"; do
        if [ -e "/usr/bin/$_arq" ]; then
            rm "/usr/bin/$_arq"
        fi

        wget -q -P /bin "https://raw.githubusercontent.com/opiran-club/opiran-panel/main/Modules/$_arq" > /dev/null 2>&1
        chmod +x "/usr/bin/$_arq" > /dev/null 2>&1
        
        echo -e "${GREEN}$_arq downloaded and configuration necessary files completed.${NC}"
    done
}


# Function to ask the user about scheduling daily reboot
ask_reboot_schedule() {
    echo -e "${CYAN}Do you want to schedule a daily reboot? [Y/N]${NC}"
 
while true; do
    read -p "Your choice [Y/N]: " -e -i Y reboot_choice

    case "$reboot_choice" in
        [Yy])
            echo -e "${YELLOW}Daily reboot (HH:MM, 24-hour format)${NC} ${RED}(ex. 03)${NC}"
            read -p "Enter the time: " -e -i 03 reboot_time
            (crontab -l 2>/dev/null; echo "$reboot_time * * * /sbin/reboot") | crontab -
            echo -e "${GREEN}Daily reboot scheduled.${NC}"
            break
            ;;
        [Nn])
            echo -e "${YELLOW}Skipping daily reboot scheduling.${NC}"
            break
            ;;
        *)
            echo -e "${RED}Invalid input. Please enter Y or N.${NC}"
            ;;
    esac
done
}

# Main script execution
    clear
    echo -e "${WHITE}────────────────────────────────────────────────────────${NC}"
    echo ""
    echo -e "                  ${MAGENTA}OPIRAN PANEL${NC}"
    echo ""
    echo -e "${WHITE}────────────────────────────────────────────────────────${NC}"
    echo -e "${YELLOW}TG-Group${NC} ${GREEN} @OPIranCluB${NC}"
    echo -e "${BLUE}────────────────────────────────────────────────────────${NC}"
    echo -e "   ${RED} ATTENTION ${NC}"
    echo ""
    echo -e "         ${GREEN}Script will install required packages${NC}"
    echo ""
    echo -e "         ${GREEN}Answer The Question, I will do the rest.${NC}"
    echo ""

# Creating necessary directories
[[ ! -d /etc/OPIranPanel ]] && mkdir /etc/OPIranPanel
[[ ! -d /etc/OPIranPanel/password ]] && mkdir /etc/OPIranPanel/password
[[ ! -e /etc/OPIranPanel/Exp ]] && touch /etc/OPIranPanel/Exp
[[ ! -d /etc/OPIranPanel/usertest ]] && mkdir /etc/OPIranPanel/usertest
[[ ! -d /etc/OPIranPanel/.tmp ]] && mkdir /etc/OPIranPanel/.tmp
# Creating necessary directories for future bot
[[ ! -d /etc/bot ]] && mkdir /etc/bot
[[ ! -d /etc/bot/info-users ]] && mkdir /etc/bot/info-users
[[ ! -d /etc/bot/files ]] && mkdir /etc/bot/files
[[ ! -d /etc/bot/reseller ]] && mkdir /etc/bot/reseller
[[ ! -d /etc/bot/suspended ]] && mkdir /etc/bot/suspended
[[ ! -e /etc/bot/list_actives ]] && touch /etc/bot/list_actives
[[ ! -e /etc/bot/list_suspended ]] && touch /etc/bot/list_suspended
# Restarting services with specific configurations
ss -nplt | grep -w 'apache2' | grep -w '80' && sed -i "s/Listen 80/Listen 8888/g" /etc/apache2/ports.conf > /dev/null 2>&1 && service apache2 restart
[[ "$(grep -o '#Port 22' /etc/ssh/sshd_config)" == "#Port 22" ]] && sed -i "s;#Port 22;Port 22;" /etc/ssh/sshd_config > /dev/null 2>&1 && service ssh restart
grep -v "^PasswordAuthentication" /etc/ssh/sshd_config > /tmp/passlogin && mv /tmp/passlogin /etc/ssh/sshd_config > /dev/null 2>&1
echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config

# check root
check_root | display_fancy_progress 10

# check root
check_install | display_fancy_progress 10

change_source_list | display_fancy_progress 10

# Install required dependencies
install_dependencies | display_fancy_progress 50

# Create Alias
setup_dibah_command

download_and_configure_scripts | display_fancy_progress 50

# Create or use an existing user database and IP address
create_user_database
ask_ip_addresses

# config reboot and cronjob and timezone
ask_reboot_schedule
ask_timezone

service cron restart >/dev/null 2>&1
service ssh restart >/dev/null 2>&1
source ~/.bashrc >/dev/null 2>&1

# Final message
echo -e "${YELLOW}COMPLETING FUNCTIONS AND SETTINGS!${NC}"
echo -e "${YELLOW} Press.....${NC} ${RED} ENTER ${NC} ${YELLOW}.....For Tip!${NC}"
read -s -r -p ""
sleep 2
clear
    echo -e "${WHITE}────────────────────────────────────────────────────────${NC}"
    echo ""
    echo -e "                  ${MAGENTA}OPIRAN PANEL${NC}"
    echo ""
    echo -e "${WHITE}────────────────────────────────────────────────────────${NC}"
    echo -e "${YELLOW}TG-Group${NC} ${GREEN} @OPIranCluB${NC}"
    echo -e "${BLUE}────────────────────────────────────────────────────────${NC}"
    echo ""
    echo -e "${YELLOW}   Main Command:${NC} ${GREEN}menu ${NC}"
    echo ""
    echo -e "$(echo -e "${CYAN}Telegram Group:${NC}") $(echo -e "${YELLOW}@OPIranclub${NC}")"
    echo -e "$(echo -e "${CYAN}OPIran Panel Official Page${NC}") $(echo -e "${YELLOW}https://github.com/opiran-club/opiran-panel${NC}")"
    echo ""
    echo -e "${RED}────────────────────────────────────────────────────────${NC}"
