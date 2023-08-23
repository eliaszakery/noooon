#!/bin/bash

CYAN="\e[36m"
GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
CYAN="\e[36m"
NC="\e[0m"

# Function to wait for user input before exiting
press_enter_to_continue() {
    echo -e "       ${YELLOW} Press.....${NC} ${RED} ENTER ${NC} ${YELLOW}.....to continue${NC}"
    read -s -r -p ""
    sleep 0.5
    clear
}

# Function to display a title before optimizing
display_optimization_title() {
    local title="$1"
    echo -e "${CYAN}Optimizing: ${YELLOW}$title${NC}"
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

clear

# Check if curl is installed, if not, install it
if ! command -v curl &>/dev/null; then
  display_optimization_title "Update and install curl"
  apt-get update
  apt-get install curl -y
  display_fancy_progress 25
fi

# Install speedtest-cli
if ! command -v speedtest-cli &>/dev/null; then
  display_optimization_title "Install Originall Speedtest"
  curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | bash
  apt-get install speedtest-cli -y
  display_fancy_progress 50
fi

# Run the speedtest and share results
speedtest

press_enter_to_continue
