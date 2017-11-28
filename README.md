# Let's Encrypt RouterOS / Mikrotik
**Let's Encrypt certificates for RouterOS / Mikrotik**

[![N|Solid](https://i.mt.lv/mtv2/logo.svg)](https://nodesource.com/products/nsolid)

### How it works:
* Dedicated Linux renew and push certificates to RouterOS / Mikrotik
* After CertBot renew your certificates
* The script connects to RouterOS / Mikrotik using DSA Key (without password or user input)
* Delete previous certificate files
* Delete the previous certificate
* Upload two new files: **Certificate** and **Key**
* Import **Certificate** and **Key**
* Change **SSTP Server Settings** to use new certificate
* Delete certificate and key files form RouterOS / Mikrotik storage

### Installation on Ubuntu 16.04
*Similar way you can use on Debian/CentOS/AMI Linux/Arch/Others*

Download the repo to your system
```sh
sudo -s
cd /opt
git clone https://github.com/gitpel/letsencrypt-routeros
```
Edit the settings file:
```sh
vim /opt/letsencrypt-routeros/letsencrypt-routeros.settings
```
| Variable Name | Data |
| ------ | ------ |
| ROUTEROS_USER | admin |
| ROUTEROS_HOST | 10.0.254.254 |
| ROUTEROS_SSH_PORT | 22 |
| ROUTEROS_PRIVATE_KEY | /opt/letsencrypt-routeros/id_dsa |
| DOMAIN | router.mydomain.com |

Change permissions:
```sh
chmod +x /opt/letsencrypt-routeros/letsencrypt-routeros.sh
```
Generate DSA Key for RouterOS

*Make sure to leave the passphrase blank (-N "")*

```sh
ssh-keygen -t dsa -f /opt/letsencrypt-routeros/id_dsa -N ""
```

Send Generated DSA Key to RouterOS / Mikrotik
```sh
source /opt/letsencrypt-routeros/letsencrypt-routeros.settings
scp -P $ROUTEROS_SSH_PORT /opt/letsencrypt-routeros/id_dsa.pub "$ROUTEROS_USER"@"$ROUTEROS_HOST":"id_dsa.pub" 
```

### Setup RouterOS / Mikrotik side
*Check that user is the same as in the settings file letsencrypt-routeros.settings*

*Check Mikrotik ssh port in /ip services ssh*

*Check Mikrotik firewall to accept on SSH port*
```sh
:put "Enable SSH"
/ip service enable ssh

:put "Add to the user DSA Public Key"
/user ssh-keys import user=admin public-key-file=id_dsa.pub
```

### CertBot Let's Encrypt
Install CertBot using official manuals https://certbot.eff.org/#ubuntuxenial-other

*for Ubuntu 16.04*
```sh
apt update
apt install software-properties-common -y
add-apt-repository ppa:certbot/certbot
apt update
apt install certbot -y
```

***In the first time, you will need to create Certificates manually and put domain TXT record***

*follow CertBot instructions*
```sh
source /opt/letsencrypt-routeros/letsencrypt-routeros.settings
certbot certonly --preferred-challenges=dns --manual -d $DOMAIN --manual-public-ip-logging-ok
```

### Usage of the script
*To use settings form the settings file:*
```sh
./opt/letsencrypt-routeros/letsencrypt-routeros.sh
```
*To use script without settings file:*

```sh
./opt/letsencrypt-routeros/letsencrypt-routeros.sh [RouterOS User] [RouterOS Host] [SSH Port] [SSH Private Key] [Domain]
```
*To use script with CertBot hooks:*
```sh
certbot certonly --preferred-challenges=dns --manual -d $DOMAIN --manual-public-ip-logging-ok --post-hook /opt/letsencrypt-routeros/letsencrypt-routeros.sh
```

### Edit Script
You can easily edit script to execute your commands on RouterOS / Mikrotik after certificates renewal

---
Licence

MIT
