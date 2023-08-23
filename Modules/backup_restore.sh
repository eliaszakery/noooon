#!/bin/bash

# Color variables
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

clear
IP=$(wget -qO- ipv4.icanhazip.com)
	
apchon () {
		if netstat -nltp|grep 'dropbear' > /dev/null; then
			[[ ! -d /var/www/html ]] && mkdir /var/www/html
			[[ ! -d /var/www/html/backup ]] && mkdir /var/www/html/backup
			touch /var/www/html/backup/index.html
			/etc/init.d/apache2 restart
		else
			apt-get install apache2 zip -y
			sed -i "s/Listen 80/Listen 8888/g" /etc/apache2/ports.conf
			service apache2 restart
			[[ ! -d /var/www/html ]] && mkdir /var/www/html
			[[ ! -d /var/www/html/backup ]] && mkdir /var/www/html/backup
			touch /var/www/html/backup/index.html
			chmod -R 755 /var/www
			/etc/init.d/apache2 restart
		fi
	}
fun_temp () {
		helice () {
			apchon > /dev/null 2>&1 & 
			tput civis
			while [ -d /proc/$! ]
			do
				for i in / - \\ \|
				do
					sleep .1
					echo -ne "\e[1D$i"
				done
			done
			tput cnorm
		}
		echo -ne "Please Wait...... "
		helice
		echo -e "\e[1DOk"
	}
geralink () {
		if [ -d /var/www/html/backup ]; then
			rm -rf /var/www/html/backup/backup.vps > /dev/null 2>&1
			cp $HOME/backup.vps /var/www/html/backup/backup.vps
			sleep 2
		fi
	}
fun_temp2 () {
		helice () {
			geralink > /dev/null 2>&1 & 
			tput civis
			while [ -d /proc/$! ]
			do
				for i in / - \\ \|
				do
					sleep .1
					echo -ne "\e[1D$i"
				done
			done
			tput cnorm
		}
		echo -ne "GENERATING LINK... "
		helice
		echo -e "\e[1DOk"
	}

main() {
    while true; do
    clear
    echo -e "${GREEN}────────────────────────────────────────────────────────${NC}"
    echo -e "    ${RED}    ─────── Backup / Restore Manager ───────${NC}"
    echo -e "${GREEN}────────────────────────────────────────────────────────${NC}"
    echo ""
    echo -e "${RED}1)${NC} ${YELLOW}CREATE BACKUP${NC}"
    echo -e "${RED}2)${NC} ${YELLOW}RESTORE BACKUP from (Dragon, OPIran) Panel${NC}"
    echo -e "${RED}M)${NC} ${YELLOW}BACK${NC}"
    echo ""
    echo -e "${GREEN}────────────────────────────────────────────────────────${NC}"
    echo ""
    echo -ne "${CYAN}WHATS YOUR CHOICE? : ${NC}"
    read -r choice

    case "$choice" in
1)
	if [ -f "/root/users.db" ]; then
	rm -rf "$HOME/backup.vps" > /dev/null 2>&1
	sleep 1
	tar cvf /root/backup.vps /root/users.db /etc/shadow /etc/passwd /etc/group /etc/gshadow /etc/OPIranPanel/password > /dev/null 2>&1
	echo ""
	echo -e " BACKUP SUCCESSFULLY CREATED!"
	echo ""
	echo -ne " GET THE LINK FOR DOWNLOAD? [Y/N]: "
	read -r resp
		if [[ "$resp" =~ ^[Yy]$ ]]; then
			echo ""
			fun_temp
			echo ""
			fun_temp2
			echo ""
			if [ -e /var/www/html/backup/backup.vps ]; then
				if [[ "$VERSION_ID" = 'VERSION_ID="14.04"' ]]; then
					echo -e " LINK: http://$IP:8888/html/backup/backup.vps"
				else
					echo -e " LINK: http://$IP:8888/backup/backup.vps"
				fi
			else
				echo -e " Available in ~/backup.vps"
			fi
		else
			echo -e "\n Available in ~/backup.vps"
			sleep 2
			main
		fi
	else
		echo ""
		echo -e " Creating backup..."
		echo ""
		tar cvf /root/backup.vps /etc/shadow /etc/passwd /etc/group /etc/gshadow /etc/OPIranPanel/password > /dev/null 2>&1
		sleep 2s
		echo ""
		echo -e " The file backup.vps"
		echo -e " has been successfully created in the directory /root"
		echo ""
	fi
;;
2)
	if [ -f "/root/backup.vps" ]; then
	echo ""
	echo -e " Restoring backup..."
	echo ""
	sleep 2s
	mkdir //temp
	tar -xvf backup.vps -C //temp
	
	if [ -f "//temp/root/usuarios.db" ]; then
		mv "//temp/root/usuarios.db" "$HOME/users.db"
	elif [ -f "//temp/root/users.db" ]; then
		mv "//temp/root/users.db" "$HOME/users.db"
	fi

	if [ -d "//temp/etc/VPSManager/senha/" ]; then
    for file in //temp/etc/VPSManager/senha/*; do
        if [ -f "$file" ]; then
            mv "$file" "/etc/OPIranPanel/password/"
        fi
    done
elif [ -d "//temp/etc/OPIranPanel/password/" ]; then
    for file in //temp/etc/OPIranPanel/password/*; do
        if [ -f "$file" ]; then
            mv "$file" "/etc/OPIranPanel/password/"
        fi
    done
fi

	if [ -f "//temp/etc/shadow" ]; then
		mv "//temp/etc/shadow" "/etc/shadow"
	fi

	if [ -f "//temp/etc/passwd" ]; then
		mv "//temp/etc/passwd" "/etc/passwd"
	fi

	if [ -f "//temp/etc/group" ]; then
		mv "//temp/etc/group" "/etc/group"
	fi

	if [ -f "//temp/etc/gshadow" ]; then
		mv "//temp/etc/gshadow" "/etc/gshadow"
	fi

	echo ""
	echo -e " Users and passwords imported successfully."
	echo ""
	exit
else
	echo ""
	echo -e " The file backup.vps was not found!"
	echo -e " Make sure it is located in the directory /root/ with the name backup.vps"
	echo ""
	exit
fi
	;;
[Mm})
	break
	;;
esac
done
}
main
