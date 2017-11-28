# Let's Encrypt RouterOS / Mikrotik
**Let's Encrypt certificates for RouterOS / Mikrotik**

### Installation on Ubuntu 16.04
**Similar way you can use for Debian/CentOS/AMI Linux**

```sh
sudo -s
cd /opt
git clone https://github.com/gitpel/letsencrypt-routeros
```
Edit the settings file:

| Variable Name | Data |
| ------ | ------ |
| ROUTEROS_USER | admin |
| ROUTEROS_HOST | 10.0.254.254 |
| ROUTEROS_SSH_PORT | 22 |
| ROUTEROS_PRIVATE_KEY | /opt/letsencrypt-routeros/id_dsa |
| DOMAIN | router.mydomain.com |

```sh
vim /opt/letsencrypt-routeros/letsencrypt-routeros.settings
```

Change permissions:
```sh
chmod +x /opt/letsencrypt-routeros/letsencrypt-routeros.sh
```
Generate DSA Key for RouterOS
*Make sure to leave the passphrase blank (-N "")*
```sh
ssh-keygen -t dsa -f /opt/letsencrypt-routeros/id_dsa -N ""
```

Send DSA 
*You will need to
```sh
source /opt/letsencrypt-routeros/letsencrypt-routeros.settings
scp -P $ROUTEROS_SSH_PORT /opt/letsencrypt-routeros/id_dsa.pub "$ROUTEROS_USER"@"$ROUTEROS_HOST":"id_dsa.pub" 
```

### Setup RouterOS / Mikrotik side
*Check that user is the same as in the settings file letsencrypt-routeros.settings*
*Check mikrotik ssh port in /ip services ssh*
*Check mikrotik firewall to accept on SSH port*
```sh
:put "Enable SSH"
/ip service enable ssh

:put "Add to the user DSA Public Key"
/user ssh-keys import user=admin public-key-file=id_dsa.pub
```

### CertBot Let's Encrypt
Install CertBot using official manuals https://certbot.eff.org/#ubuntuxenial-other
For Ubuntu 16.04
```sh
apt update
apt install software-properties-common -y
add-apt-repository ppa:certbot/certbot
apt update
apt install certbot -y
```

***In the first time you will need to create Certificates manually and put domain TXT record***
*follow the certbot instructions*
```sh
source /opt/letsencrypt-routeros/letsencrypt-routeros.settings
certbot certonly --preferred-challenges=dns --manual -d $DOMAIN --manual-public-ip-logging-ok"
```

### Usage:
```sh
letsencrypt-routeros.sh
```
or:
```sh
letsencrypt-routeros.sh [RouterOS User] [RouterOS Host] [SSH Port] [SSH Private Key] [Domain]
```
