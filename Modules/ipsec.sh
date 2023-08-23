#!/bin/bash

CYAN="\e[36m"
GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
CYAN="\e[36m"
NC="\e[0m"

read -p "Do you want to fill in the parameters for vpn.sh? (y/n): " fill_params
           
           if [[ $fill_params == "y" || $fill_params == "Y" ]]; then
               # Run the command to download the vpn.sh file
               wget https://get.vpnsetup.net -O etc/OPIranPanel/vpn.sh
           
               # Check if the download was successful
                if [ $? -eq 0 ] && [ -f "etc/OPIranPanel/vpn.sh" ]; then
               # Ask the user for the necessary parameters
               read -p "Enter your IPSEC PSK: " ipsec_psk
               read -p "Enter your username: " username
               read -sp "Enter your password: " password
           
               # Fill in the necessary information in the vpn.sh file
                sed -i "s/YOUR_IPSEC_PSK=''/YOUR_IPSEC_PSK='$ipsec_psk'/g" etc/OPIranPanel/vpn.sh
                sed -i "s/YOUR_USERNAME=''/YOUR_USERNAME='$username'/g" etc/OPIranPanel/vpn.sh

                # Append the password using a secure method
                echo "YOUR_PASSWORD='$password'" >> etc/OPIranPanel/vpn.sh

                echo "Setup complete! Your vpn.sh file has been updated with your parameters."
            else
                echo "Failed to download vpn.sh. Exiting..."
                exit 1
            fi
        fi
           # Run the command to execute the vpn.sh file
                sudo sh etc/OPIranPanel/vpn.sh
                echo -e "Press ${RED}ENTER${NC} to continue"
                read
                show_CONNECTION_PROTOCLE_submenu