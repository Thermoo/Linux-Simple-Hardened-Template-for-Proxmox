#!/bin/bash
# Simple Script for hardening a Linux installation. This was tested in an Ubuntu LXC inside of Proxmox
# Author: Thermoo

echo "Updating System!"
sudo apt update && sudo apt upgrade -y

echo "Installing Security Essentials!"
sudo apt install -y openssh-server ufw fail2ban unattended-upgrades sudo rkhunter 

echo "Enabling Security Services on Boot!"
sudo systemctl enable fail2ban --now
echo "Configuring UFW Firewall and enabling SSH"
sudo ufw allow ssh
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw --force enable

echo "Configuring Automatic Security Updates!"
sudo dpkg-reconfigure -plow unattended-upgrades

echo "Hardening SSH Configuration!"
sudo sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config
sudo systemctl restart ssh

echo "Configuring Session Settings!"
echo "readonly TMOUT=900 export TMOUT" | sudo tee /etc/profile.d/idle_timeout.sh
sudo chmod 644 /etc/profile.d/idle_timeout.sh

echo "Sanitizing System!"
sudo truncate -s 0 /etc/machine-id
sudo apt clean

echo "Hardening Complete! Your system is ready for use or to be used as a template."

