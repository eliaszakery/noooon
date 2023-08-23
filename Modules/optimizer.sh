#!/bin/bash

CYAN="\e[36m"
GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
CYAN="\e[36m"
NC="\e[0m"

# Declare Paths
SYS_PATH="/etc/sysctl.conf"
LIM_PATH="/etc/security/limits.conf"
PROF_PATH="/etc/profile"
SSH_PATH="/etc/ssh/sshd_config"
DNS_PATH="/etc/resolv.conf"

# Function to display a title before optimizing
display_optimization_title() {
    local title="$1"
    echo -e "${CYAN}Optimizing: ${YELLOW}$title${NC}"
}

# Function to wait for user input before exiting
press_enter_to_continue() {
    echo -e "       ${YELLOW} Press.....${NC} ${RED} ENTER ${NC} ${YELLOW}.....to continue${NC}"
    read -s -r -p ""
    sleep 0.5
    clear
}

# Function to display a fancier progress bar
display_fancy_progress() {
    local duration=$1
    local sleep_interval=0.1
    local progress=0
    local bar_length=40

    while [ $progress -lt $duration ]; do
        echo -ne "\r[${YELLOW}"
        for ((i = 0; i < bar_length; i++)); do
            if [ $i -lt $((progress * bar_length / duration)) ]; then
                echo -ne "#"
            else
                echo -ne "-"
            fi
        done
        echo -ne "${RED}] ${progress}%"
        progress=$((progress + 1))
        sleep $sleep_interval
    done
    echo -ne "\r[${YELLOW}"
    for ((i = 0; i < bar_length; i++)); do
        echo -ne "#"
    done
    echo -ne "${RED}] ${progress}%"
    echo
}

# Check root access
check_root() {
    display_optimization_title "Checking the root previllage"
  if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}Please run this script as root!${NC}"
    exit 1
  fi
}

# Function to change the package repository source list
change_source_list() {
    display_optimization_title "Package Repository Source List"
    if [ -f "/etc/os-release" ]; then
        source /etc/os-release
        case "$ID" in
            debian|ubuntu)
                echo -e "${CYAN}Updating package repository source list for $ID...${NC}"
                # Add your custom source list entries here
                if [ "$ID" == "debian" ]; then
                    echo "deb  http://ftp.de.debian.org/ubuntu/ bullseye main contrib non-free" > /etc/apt/sources.list
                    echo "deb  http://ftp.de.debian.org/debian/ bullseye-updates main contrib non-free" >> /etc/apt/sources.list
                    echo "deb  http://ftp.de.debian.org/debian/ bullseye-backports main contrib non-free" >> /etc/apt/sources.list
                    echo "deb  http://ftp.de.debian.org/debian-security bullseye-security main contrib non-free" >> /etc/apt/sources.list
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

# Fix DNS
fix_dns() {
    display_optimization_title "Fixing DNS resolv"
  DNS_PATH="/etc/resolv.conf"

  if [[ ! -w "$DNS_PATH" ]]; then
    echo -e "${RED}Error: Cannot modify $DNS_PATH. Check permissions or run with root privileges.${NC}"
    exit 1
  fi

  sed -i '/^nameserver/d' "$DNS_PATH"
  echo 'nameserver 8.8.8.8' >> "$DNS_PATH"
  echo 'nameserver 1.1.1.1' >> "$DNS_PATH"
  echo -e "${GREEN}System DNS Optimized.${NC}"
}


# Check OS compatibility
check_os() {
    display_optimization_title "Finding your OS"
  supported_os=("debian" "ubuntu")
  current_os=$(grep -i pretty_name /etc/os-release 2>/dev/null | cut -d \" -f2 | tr '[:upper:]' '[:lower:]')

  for os in "${supported_os[@]}"; do
    if [[ "$current_os" =~ $os ]]; then
      return 0
    fi
  done

  echo -e "${RED}Your OS is not supported. Supported OS: Debian, Ubuntu, CentOS, Alpine, Arch.${NC}"
  exit 1
}

# Update & Upgrade & Remove & Clean
complete_update() {
    display_optimization_title "Update and Upgrade Your Server"
  apt-get update
  apt-get -y upgrade
}

## Install useful packages
installations() {
    display_optimization_title "Install all required Packages"
  apt-get -y install nload nethogs autossh ssh iperf sshuttle software-properties-common apt-transport-https iptables lsb-release ca-certificates ubuntu-keyring gnupg2 apt-utils cron bash-completion curl git unzip zip ufw wget preload locales nano vim python3 jq qrencode socat busybox net-tools haveged htop
  sleep 0.5
  
}

# Enable packages at server boot
enable_packages() {
  systemctl enable preload haveged snapd cron
}

## Swap Maker
swap_maker() {
    display_optimization_title "Adjusting Swap path and size"
  # 2 GB Swap Size
  SWAP_SIZE=2G

  # Default Swap Path
  SWAP_PATH="/swapfile"

  # Make Swap
  fallocate -l $SWAP_SIZE $SWAP_PATH
  chmod 600 $SWAP_PATH
  mkswap $SWAP_PATH
  swapon $SWAP_PATH
  echo "$SWAP_PATH   none    swap    sw    0   0" >>/etc/fstab
  echo -e "${GREEN}SWAP Optimized.${NC}"
  echo

}

enable_ipv6_support() {
    display_optimization_title "Enabling IPV6 if it supported by your VPS"
  if [[ $(sysctl -a | grep 'disable_ipv6.*=.*1') || $(cat /etc/sysctl.{conf,d/*} | grep 'disable_ipv6.*=.*1') ]]; then
    sed -i '/disable_ipv6/d' /etc/sysctl.{conf,d/*}
    echo 'net.ipv6.conf.all.disable_ipv6 = 0' >/etc/sysctl.d/ipv6.conf
    sysctl -w net.ipv6.conf.all.disable_ipv6=0
  fi
}

# Remove Old SYSCTL Config to prevent duplicates.
remove_old_sysctl() {
    display_optimization_title "Updating sysctl configuration"
  sed -i '/fs.file-max/d' $SYS_PATH
  sed -i '/fs.inotify.max_user_instances/d' $SYS_PATH

  sed -i '/net.ipv4.tcp_syncookies/d' $SYS_PATH
  sed -i '/net.ipv4.tcp_fin_timeout/d' $SYS_PATH
  sed -i '/net.ipv4.tcp_tw_reuse/d' $SYS_PATH
  sed -i '/net.ipv4.ip_local_port_range/d' $SYS_PATH
  sed -i '/net.ipv4.tcp_max_syn_backlog/d' $SYS_PATH
  sed -i '/net.ipv4.tcp_max_tw_buckets/d' $SYS_PATH
  sed -i '/net.ipv4.route.gc_timeout/d' $SYS_PATH

  sed -i '/net.ipv4.tcp_syn_retries/d' $SYS_PATH
  sed -i '/net.ipv4.tcp_synack_retries/d' $SYS_PATH
  sed -i '/net.core.somaxconn/d' $SYS_PATH
  sed -i '/net.core.netdev_max_backlog/d' $SYS_PATH
  sed -i '/net.ipv4.tcp_timestamps/d' $SYS_PATH
  sed -i '/net.ipv4.tcp_max_orphans/d' $SYS_PATH
  #IPv6
  sed -i '/net.ipv6.conf.all.disable_ipv6/d' $SYS_PATH
  sed -i '/net.ipv6.conf.default.disable_ipv6/d' $SYS_PATH
  sed -i '/net.ipv6.conf.all.forwarding/d' $SYS_PATH
  # System Limits.
  sed -i '/soft/d' $LIM_PATH
  sed -i '/hard/d' $LIM_PATH
  # BBR
  sed -i '/net.core.default_qdisc/d' $SYS_PATH
  sed -i '/net.ipv4.tcp_congestion_control/d' $SYS_PATH
  sed -i '/net.ipv4.tcp_ecn/d' $SYS_PATH
  # uLimit
  sed -i '/1000000/d' $PROF_PATH
  #SWAP
  sed -i '/vm.swappiness/d' $SYS_PATH
  sed -i '/vm.vfs_cache_pressure/d' $SYS_PATH

}

## SYSCTL Optimization
sysctl_optimizations() {
    display_optimization_title "Optimizing sysctl and network configuration"
  # Optimize Swap Settings
  echo 'vm.swappiness=10' >>$SYS_PATH
  echo 'vm.vfs_cache_pressure=50' >>$SYS_PATH
  sleep 0.5

  # Optimize Network Settings
  echo 'fs.file-max = 1000000' >>$SYS_PATH

  echo 'net.core.rmem_default = 1048576' >>$SYS_PATH
  echo 'net.core.rmem_max = 2097152' >>$SYS_PATH
  echo 'net.core.wmem_default = 1048576' >>$SYS_PATH
  echo 'net.core.wmem_max = 2097152' >>$SYS_PATH
  echo 'net.core.netdev_max_backlog = 16384' >>$SYS_PATH
  echo 'net.core.somaxconn = 32768' >>$SYS_PATH
  echo 'net.ipv4.tcp_fastopen = 3' >>$SYS_PATH
  echo 'net.ipv4.tcp_mtu_probing = 1' >>$SYS_PATH

  echo 'net.ipv4.tcp_retries2 = 8' >>$SYS_PATH
  echo 'net.ipv4.tcp_slow_start_after_idle = 0' >>$SYS_PATH

  echo 'net.ipv6.conf.all.disable_ipv6 = 0' >>$SYS_PATH
  echo 'net.ipv6.conf.default.disable_ipv6 = 0' >>$SYS_PATH
  echo 'net.ipv6.conf.all.forwarding = 1' >>$SYS_PATH

  # Use BBR
  echo 'net.core.default_qdisc = fq' >>$SYS_PATH
  echo 'net.ipv4.tcp_congestion_control = bbr' >>$SYS_PATH

  sysctl -p
  echo
  echo -e "${GREEN}Network Optimized.${NC}"
  echo
}

# Remove old SSH config to prevent duplicates.
remove_old_ssh_conf() {
    display_optimization_title "updat and optimizing SSH configuration"
  # Make a backup of the original sshd_config file
  cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

  echo
  echo -e "${GREEN}Default SSH Config file Saved. Directory: /etc/ssh/sshd_config.bak${NC}"
  echo
  sleep 1

  # Disable DNS lookups for connecting clients
  sed -i 's/#UseDNS yes/UseDNS no/' $SSH_PATH

     display_optimization_title "Disable DNS lookups for connecting clients"
  # Enable compression for SSH connections
  sed -i 's/#Compression no/Compression yes/' $SSH_PATH

  # Remove less efficient encryption ciphers
  sed -i 's/Ciphers .*/Ciphers aes256-ctr,chacha20-poly1305@openssh.com/' $SSH_PATH

  # Remove these lines
  sed -i '/MaxAuthTries/d' $SSH_PATH
  sed -i '/MaxSessions/d' $SSH_PATH
  sed -i '/TCPKeepAlive/d' $SSH_PATH
  sed -i '/ClientAliveInterval/d' $SSH_PATH
  sed -i '/ClientAliveCountMax/d' $SSH_PATH
  sed -i '/AllowAgentForwarding/d' $SSH_PATH
  sed -i '/AllowTcpForwarding/d' $SSH_PATH
  sed -i '/GatewayPorts/d' $SSH_PATH
  sed -i '/PermitTunnel/d' $SSH_PATH

}

## Update SSH config
update_sshd_conf() {
  # Enable TCP keep-alive messages
  echo "TCPKeepAlive yes" | tee -a $SSH_PATH

  # Configure client keep-alive messages
  echo "ClientAliveInterval 3000" | tee -a $SSH_PATH
  echo "ClientAliveCountMax 100" | tee -a $SSH_PATH

  # Permit Root Login
  echo "PermitRootLogin yes" >>/etc/ssh/sshd_config

  # Allow agent forwarding
  echo "AllowAgentForwarding yes" | tee -a $SSH_PATH

  # Allow TCP forwarding
  echo "AllowTcpForwarding yes" | tee -a $SSH_PATH

  # Enable gateway ports
  echo "GatewayPorts yes" | tee -a $SSH_PATH

  # Enable tunneling
  echo "PermitTunnel yes" | tee -a $SSH_PATH

  # Restart the SSH service to apply the changes
  service ssh restart

  echo
  echo -e "${GREEN}SSH Optimized Successfully!${NC}"
  echo
}

# System Limits Optimizations
limits_optimizations() {
    display_optimization_title "System Limits Optimizations"

  echo '* soft     nproc          655350' >>$LIM_PATH
  echo '* hard     nproc          655350' >>$LIM_PATH
  echo '* soft     nofile         655350' >>$LIM_PATH
  echo '* hard     nofile         655350' >>$LIM_PATH

  echo 'root soft     nproc          655350' >>$LIM_PATH
  echo 'root hard     nproc          655350' >>$LIM_PATH
  echo 'root soft     nofile         655350' >>$LIM_PATH
  echo 'root hard     nofile         655350' >>$LIM_PATH

  sysctl -p
  echo
   echo -e "${GREEN}System Limits Optimized.${NC}"
  echo
}

# RUN BABY, RUN
clear
check_root
display_fancy_progress 10

display_optimization_title "Package Repository Source List"
change_source_list
display_fancy_progress 25

display_optimization_title "DNS"
fix_dns
display_fancy_progress 10

display_optimization_title "Checking OS Compatibility"
check_os
display_fancy_progress 25

display_optimization_title "Complete Update"
complete_update
display_fancy_progress 100

display_optimization_title "Installing Useful Packages"
installations
display_fancy_progress 100

display_optimization_title "Enabling Packages"
enable_packages
display_fancy_progress 25

display_optimization_title "Creating Swap"
swap_maker
display_fancy_progress 25

display_optimization_title "Enabling IPv6 Support"
enable_ipv6_support
display_fancy_progress 10

display_optimization_title "Removing Old Sysctl Config"
remove_old_sysctl
display_fancy_progress 10

display_optimization_title "Applying Sysctl Optimizations"
sysctl_optimizations
display_fancy_progress 10

display_optimization_title "Removing Old SSH Config"
remove_old_ssh_conf
display_fancy_progress 10

display_optimization_title "Updating SSH Config"
update_sshd_conf
display_fancy_progress 10

display_optimization_title "Applying System Limits Optimizations"
limits_optimizations
display_fancy_progress 15

# Clear the screen and center the message
clear
columns=$(tput cols)
rows=$(tput lines)
center_row=$((rows / 2))
center_col=$((columns / 2))
message="FOR BETTER PERFORMANCE PLEASE REBOOT"

# Calculate the position for centered output
message_length=${#message}
start_col=$((center_col - (message_length / 2)))
start_row=$center_row

# Display the message in the center of the terminal
tput cup $start_row $start_col
echo -e "${RED}============================================${NC}"
tput cup $((start_row + 1)) $start_col
echo -e "${YELLOW}$message${NC}"
tput cup $((start_row + 2)) $start_col
echo -e "${RED}============================================${NC}"
sleep 1
echo ""
echo -e "${GREEN}Optimization Process Completed, Use >>>> reboot <<<< in terminal${NC}"
echo ""
press_enter_to_continue
