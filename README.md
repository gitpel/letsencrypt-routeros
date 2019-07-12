# Let's Encrypt RouterOS / Mikrotik
**Let's Encrypt certificates for RouterOS / Mikrotik**

*UPD 2018-05-27: Works with wildcard Let's Encrypt Domains*

*UPD 2019-07-11: Works with OpenSSH 7+*

[![Mikrotik](https://i.mt.lv/mtv2/logo.svg)](https://mikrotik.com/)


### How it works:
* Dedicated Linux renew and push certificates to RouterOS / Mikrotik
* After CertBot renew your certificates
* The script connects to RouterOS / Mikrotik using RSA Key (without password or user input)
* Delete previous certificate files
* Delete the previous certificate
* Upload two new files: **Certificate** and **Key**
* Import **Certificate** and **Key**
* Change **SSTP Server Settings** to use new certificate
* Change **WWW-SSL Service** to use new certificate
* Change **API-SSL Service** to use new certificate
* Delete certificate and key files from RouterOS / Mikrotik storage

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
| Variable Name | Value | Description |
| ------ | ------ | ------ |
| ROUTEROS_USER | admin | user with admin rights to connect to RouterOS |
| ROUTEROS_HOST | 10.0.254.254 | RouterOS\Mikrotik IP |
| ROUTEROS_SSH_PORT | 22 | RouterOS\Mikrotik PORT |
| ROUTEROS_PRIVATE_KEY | /opt/letsencrypt-routeros/id_rsa | Private RSA Key to connecto to RouterOS |
| DOMAIN | mydomain.com | Use main domain for wildcard certificate or subdomain for subdomain certificate |


Change permissions:
```sh
chmod +x /opt/letsencrypt-routeros/letsencrypt-routeros.sh
```
Generate RSA Key for RouterOS

*Make sure to leave the passphrase blank (-N "")*

```sh
ssh-keygen -t rsa -f /opt/letsencrypt-routeros/id_rsa -N ""
```

Send Generated RSA Key to RouterOS / Mikrotik
```sh
source /opt/letsencrypt-routeros/letsencrypt-routeros.settings
scp -P $ROUTEROS_SSH_PORT /opt/letsencrypt-routeros/id_rsa.pub "$ROUTEROS_USER"@"$ROUTEROS_HOST":"id_rsa.pub" 
```

### Setup RouterOS / Mikrotik side
*Check that user is the same as in the settings file letsencrypt-routeros.settings*

*Check Mikrotik ssh port in /ip services ssh*

*Check Mikrotik firewall to accept on SSH port*
```sh
:put "Enable SSH"
/ip service enable ssh

:put "Add to the user RSA Public Key"
/user ssh-keys import user=admin public-key-file=id_rsa.pub
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
*To use settings from the settings file:*
```sh
./opt/letsencrypt-routeros/letsencrypt-routeros.sh
```
*To use script without settings file:*

```sh
./opt/letsencrypt-routeros/letsencrypt-routeros.sh [RouterOS User] [RouterOS Host] [SSH Port] [SSH Private Key] [Domain]
```
*To use script with CertBot hooks for wildcard domain:*
```sh
certbot certonly --preferred-challenges=dns --manual -d *.$DOMAIN --manual-public-ip-logging-ok --post-hook /opt/letsencrypt-routeros/letsencrypt-routeros.sh --server https://acme-v02.api.letsencrypt.org/directory
```
*To use script with CertBot hooks for subdomain:*
```sh
certbot certonly --preferred-challenges=dns --manual -d $DOMAIN --manual-public-ip-logging-ok --post-hook /opt/letsencrypt-routeros/letsencrypt-routeros.sh
```

---
### Licence MIT
Copyright 2018 Konstantin Gimpel

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
