#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status

# ASCII Art
clear
echo """
██████╗ ███████╗███████╗    ██╗███╗   ██╗███╗   ██╗ ██████╗ ██╗   ██╗ █████╗ ████████╗██╗██╗   ██╗███████╗
██╔══██╗██╔════╝██╔════╝    ██║████╗  ██║████╗  ██║██╔═══██╗██║   ██║██╔══██╗╚══██╔══╝██║██║   ██║██╔════╝
██████╔╝█████╗  █████╗      ██║██╔██╗ ██║██╔██╗ ██║██║   ██║██║   ██║███████║   ██║   ██║██║   ██║█████╗  
██╔══██╗██╔══╝  ██╔══╝      ██║██║╚██╗██║██║╚██╗██║██║   ██║╚██╗ ██╔╝██╔══██║   ██║   ██║╚██╗ ██╔╝██╔══╝  
██████╔╝███████╗███████╗    ██║██║ ╚████║██║ ╚████║╚██████╔╝ ╚████╔╝ ██║  ██║   ██║   ██║ ╚████╔╝ ███████╗
╚═════╝ ╚══════╝╚══════╝    ╚═╝╚═╝  ╚═══╝╚═╝  ╚═══╝ ╚═════╝   ╚═══╝  ╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═══╝  ╚══════╝
"""
echo "Installing BeeInnovative Client Software..."

spinner() {
    local pid=$1
    local delay=0.1
    local spin='|/-\'
    while ps -p $pid > /dev/null; do
        for i in $(seq 0 3); do
            echo -ne "\r${spin:$i:1} "
            sleep $delay
        done
    done
    echo -ne "\r"
}

step() {
    local step_num=$1
    local total_steps=$2
    local message=$3
    echo -ne "   [Step $step_num/$total_steps] $message... "
}

create_env_file() {
    local env_file="/opt/beeInnovativeClient/.env"
    echo -n "" > $env_file
    for arg in "$@"; do
        echo "$arg" >> $env_file
    done
}

create_systemd_service() {
    local service_file="/etc/systemd/system/beeInnovativeClient.service"
    cat <<EOF > $service_file
[Unit]
Description=BeeInnovative Client Service
After=network.target

[Service]
ExecStart=/opt/beeInnovativeClient/start.sh
WorkingDirectory=/opt/beeInnovativeClient
Restart=always
User=root
StandardOutput=append:/var/log/beeInnovativeClient.log
StandardError=append:/var/log/beeInnovativeClient.log

[Install]
WantedBy=multi-user.target
EOF
    systemctl daemon-reload
    systemctl enable beeInnovativeClient.service
}

TOTAL_STEPS=10

# Ensure Git is installed
step 1 $TOTAL_STEPS "Checking for Git"
(sudo apt update -qq > /dev/null 2>&1 && sudo apt install -y -qq git cron > /dev/null 2>&1) & spinner $!
printf "\r"
printf "\r\n"

# Ensure Python 3.11.2 is installed
step 2 $TOTAL_STEPS "Checking for Python 3.11.2"
(if ! python3.11 --version | grep -q "3.11.2"; then sudo apt update -qq > /dev/null 2>&1 && sudo apt install -y -qq python3.11 python3.11-venv python3.11-dev > /dev/null 2>&1; fi) & spinner $!
printf "\r"
printf "\r\n"

# Clone repository
step 3 $TOTAL_STEPS "Cloning BeeInnovative Client repository"
(sudo git clone https://github.com/Project4-0S1/beeInnovativeClient.git /opt/beeInnovativeClient > /dev/null 2>&1 || true) & spinner $!
printf "\r"
printf "\r\n"

# Change directory
step 4 $TOTAL_STEPS "Navigating to /opt/beeInnovativeClient"
(cd /opt/beeInnovativeClient > /dev/null 2>&1) & spinner $!
printf "\r"
printf "\r\n"

# Create virtual environment
step 5 $TOTAL_STEPS "Creating Python virtual environment"
(python3.11 -m venv /opt/beeInnovativeClient/client > /dev/null 2>&1) & spinner $!
printf "\r"
printf "\r\n"

# Install dependencies
step 6 $TOTAL_STEPS "Installing Python requirements"
(source /opt/beeInnovativeClient/client/bin/activate && pip install --no-cache-dir --upgrade pip > /dev/null 2>&1 && pip install --no-cache-dir -r /opt/beeInnovativeClient/requirements.txt > /dev/null 2>&1) & spinner $!
printf "\r"
printf "\r\n"

# Create .env file
step 7 $TOTAL_STEPS "Creating .env file"
create_env_file "$@"
printf "\r"
printf "\r\n"

# Create and start systemd service
step 8 $TOTAL_STEPS "Creating and starting systemd service"
create_systemd_service
printf "\r"
printf "\r\n"

# Add cron job
step 9 $TOTAL_STEPS "Adding cron job"
(crontab -l 2>/dev/null | grep -v "/opt/beeInnovativeClient/publishDetections.py"; echo "*/2 * * * * cd /opt/beeInnovativeClient && /opt/beeInnovativeClient/client/bin/python3 /opt/beeInnovativeClient/publishDetections.py") | crontab -
printf "\r"
printf "\r\n"


echo "[Step 10/$TOTAL_STEPS] Installation completed. You can start the app with:"
echo "systemctl start beeInnovativeClient.service"