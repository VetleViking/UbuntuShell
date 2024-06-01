## Script for å sette opp statisk IP og/eller SSH på ubuntu-server

### kjøre shell scriptet
sette opp script
```bash
git clone https://github.com/VetleViking/UbuntuShell
cd UbuntuShell
chmod +x setup.sh
```
kjøre det for begge
```bash 
sudo ./setup.sh both <user_name> <pub_key> <static_ip> <gateway> <subnet_mask>
```
kjøre det for statisk ip
```bash 
sudo ./setup.sh net <static_ip> <gateway> <subnet_mask>
```
kjøre det for SSH
```bash 
sudo ./setup.sh ssh <user_name> <pub_key>
```
