# **Linux Simple Hardened Template for Proxmox**  

This is a simple template I created for Proxmox that allows for the cloning of a more secure and hardened version of an Ubuntu LXC container. It is intended to be run with **as minimal specs as possible** as to allow for many of these to be run at once.  
These steps and the script can also be executed inside of an actual Ubuntu OS, but the instructions here will be talking specifically about deploying inside of Proxmox.  

This repository contains a Bash script, `harden.sh`, designed to take a fresh Ubuntu LXC Container and harden it into a secure, baseline "Hardened image" for use in a Proxmox homelab environment.  

By converting a hardened container into a Proxmox Template, you can ensure that all future deployed services start from a secure, auditable, and patched foundation.  

## Security Features include:  
**- SSH Hardening** - Disabling password authentication & enforcing Ed25519/RSA key-based authentication  
**- UFW firewall configuration** - Configured with a strict deny incoming policy (besides SSH)  
**- Fail2Ban** - Automatically blocking brute-force SSH attacks  
**- Unattended-upgrades** - Automated Patching allows for critical security updates to be installed without user input  
**- RKHunter** - On-demand RootKit & backdoor auditing  
**- Session Management** - 15-minute global idle timeout to mitigate abandoned session hijacking. Also features a configured SSH pre-login legal warning banner  

  
	
## Setting up the Configuration
**IMPORTANT: DO NOT run the setup script until you have configured SSH key Authentication.**  
This script disables password authentication for SSH. If you run this script before adding your public key to the container, you will be permanently locked out of remote SSH access.  
### Deployment Instructions:  

In Proxmox, create a new **Ubuntu Unprivileged LXC.**
Start the container and log in via the Proxmox web console as `root`.
Create a standard administrative user (e.g., admin1) and grant `sudo` privileges.
```bash
apt update && apt upgrade -y
apt install git -y
adduser YOURUSER
usermod -aG sudo YOURUSER
```

### How to set up your SSH key:
**On your Personal Computer,** generate a key if you haven't already:
```bash
ssh-keygen -t ed25519 -C "YOUR-EMAIL@EXAMPLE.COM"
```  
It will generate a public and private key at the specified file path. Find and copy the entire line of the **Public** key, NOT the private key.  

Take that public key into your Proxmox container and run:
```bash
su - YOURUSER
```
Create the SSH directory and authorized keys file:
```bash
mkdir -p ~/.ssh
nano ~/.ssh/authorized_keys
```
Paste your **public key** into the file, save, and exit.  
Secure the file permissions:
```bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
```

Turn off password SSH login and restart SSH:
```bash
sudo sed -i 's/^#\?PasswordAuthentication .*/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo systemctl restart ssh
```
  
Test your Connection: Open a terminal on your personal computer and verify you can SSH into the container as your user without typing a password.  

If you get a `Permission Denied:publickey`, make sure you copied the entire line of the public key including the part at the beginning and end.

## Running the Script
Before running the script, make sure you were able to successfully SSH into the container.  

While logged in via SSH as your created user, clone this repository:
```bash
git clone https://github.com/Thermoo/Linux-Simple-Hardened-Template-for-Proxmox.git
cd Linux-Simple-Hardened-Template-for-Proxmox
```
```bash
chmod +x harden.sh
```
Execute the script:  
```bash
sudo ./harden.sh
```
  ## Converting to Template  

Once the script completes successfully, shut down the container.   

In the Proxmox Web GUI, right-click the stopped container and select Convert to template.  

Now that you have created this template, whenever you need a server you just right-click your template and select clone (Always use a Full Clone).  

Your new cloned containers will boot up with UFW enabled, Fail2Ban guarding SSH, and all password logins securely disabled.






  


