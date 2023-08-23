#!/bin/bash

CYAN="\e[36m"
GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
CYAN="\e[36m"
NC="\e[0m"

		    clear
            echo -e "${GREEN}────────────────────────────────────────────────────────${NC}"
            echo -e "        ${WHITE}───── MANAGE OpenSSH  ─────${NC}"
            echo -e "${RED}────────────────────────────────────────────────────────${NC}"
            echo ""
            echo -e "${RED} 1)${NC} => ${CYAN}ADD SSH PORT${NC}"
            echo -e "${RED} 2)${NC} => ${CYAN}REMOVE SSH PORT${NC}"
            echo -e "${RED} M)${NC} => ${CYAN}Main Menu${NC}"
            echo ""
            echo -e "${RED}────────────────────────────────────────────────────────${NC}"
            echo -ne "${YELLOW}WHAT DO YOU WANT TO DO ?${NC}${CYAN}${NC} "
            read resp
		if [[ "$resp" = '1' ]]; then
			clear
			echo -e "${GREEN}         ADD PORT TO SSH         ${NC}"
			echo -ne "${YELLOW}WHICH PORT DO YOU WANT TO ADD ?${NC}${CYAN}${NC} "
			read pt
			[[ -z "$pt" ]] && {
				echo -e "${RED}Invalid Port!${NC}"
				sleep 3
				continue
			}
			verif_ptrs $pt
			echo -e "${YELLOW}ADDING PORT TO SSH${NC}"
			echo ""
			fun_addpssh() {
				echo "Port $pt" >>/etc/ssh/sshd_config
				service ssh restart
			}
			fun_bar 'fun_addpssh'
			echo -e "${GREEN}SUCCESSFULLY ADDED PORT${NC}"
			sleep 3
			continue
		elif [[ "$resp" = '2' ]]; then
			clear
			echo -e "${GREEN}         REMOVE SSH PORT         ${NC}"
			echo -e "\n\033[1;33m[\033[1;31m!\033[1;33m] \033[1;32mSTANDARD PORT \033[1;37m22 \033[1;33mCAUTION !\033[0m"
			echo -e "\n\033[1;33mPORTS IN USE: \033[1;37m$(grep 'Port' /etc/ssh/sshd_config | cut -d' ' -f2 | grep -v 'no' | xargs)\n"
			echo -ne "${YELLOW}WHICH PORT DO YOU WANT TO REMOVE ?${NC} "
			read pt
			[[ -z "$pt" ]] && {
				echo -e "${RED}Invalid Port!${NC}"
				sleep 2
				continue
			}
			[[ $(grep -wc "$pt" '/etc/ssh/sshd_config') != '0' ]] && {
				echo -e "${YELLOW}REMOVING SSH PORT${NC}"
				echo ""
				fun_delpssh() {
					sed -i "/Port $pt/d" /etc/ssh/sshd_config
					service ssh restart
				}
				fun_bar 'fun_delpssh'
				echo -e "${GREEN}SUCCESSFULLY REMOVED PORT${NC}"
				sleep 2
				continue
			} || {
				echo -e "${RED}Invalid Port!${NC}"
				sleep 2
				continue
			}
		elif [[ "$resp" = [Mm] ]]; then
			echo -e "${RED}returning..${NC}"
			sleep 2
			break
		else
			echo -e "${RED}Invalid option!${NC}"
			sleep 2
			continue
		fi
