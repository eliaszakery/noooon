#!/bin/bash

uninstall_opiran_panel() {
    # List of packages to remove
    packages=(
        screen
        nmap
        figlet
        squid
        squid3
        dropbear
        apache2
    )

    # Remove packages
    for pkg in "${packages[@]}"; do
        apt-get purge "$pkg" -y > /dev/null 2>&1
    done

    # List of files to remove
        files_to_remove=("limiter_dropbear.sh" "limiter_ssh.sh" "add_banner.sh" "wsproxy.sh" "add_domain.sh" "backup_restore.sh" "badvpn.sh" "cfwarp.sh" "create_bulkuser.sh" "create_test.sh" "create_user.sh" "expired.sh" "fandt.sh" "info_users.sh" "ip-block.sh" "monitor_online.sh" "menu.sh" "modify_expiry&monitor.sh" "modify_limit.sh" "modify_password.sh" "optimizer.sh" "speedtest.sh" "traffic.sh" "uninstall.sh" "user_remover.sh" "chisel.sh" "dropbear.sh" "ipsec.sh" "iptable.sh" "openssh.sh" "reality.sh" "ssl.sh" "v2panel.sh" "wiregaurd.sh" "wsproxy.py")
        
        # Remove panel-specific binaries
        for file in "${files_to_remove[@]}"; do
            rm -f "/bin/$file" > /dev/null 2>&1
        done
        
    # Remove OPIranPanel directory
    rm -rf /etc/OPIranPanel > /dev/null 2>&1

    # Clear history and exit
    clear
    echo -e "\033[1;36mThank you for using OPIranPanel\033[1;33m"
    sleep 2
    cat /dev/null > ~/.bash_history && history -c && exit 0
}

clear
echo -e "\033[1;32mWANT TO UNINSTALL OPIran Panel\033[1;33m"
read -p "Want to remove? [y/n] " resp
if [[ "$resp" = y || "$resp" = Y ]]; then
    uninstall_opiran_panel
else
    echo -e "\033[1;32CTRL+C to exit\033[1;33m"
    sleep 3
    menu
fi
