## Scripts og sånt for å gjøre eksamen lettere for meg

### ssh greier
første gang
```bash
ssh -i .ssh/id_rsa [brukernavn]@[ip-adresse]
```
etter det
```bash
ssh [brukernavn]@[ip-adresse]
```
### kjøre shell scriptet
sette ting opp
```bash
git clone https://github.com/VetleViking/UbuntuShell
cd UbuntuShell
chmod +x setup.sh
```
kjøre det med begge
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
