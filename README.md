# letsencrypt-routeros
Let's Encrypt certificates for RouterOS / Mikrotik

###First Run
```sh
sudo -s
cd /opt
git clone https://github.com/gitpel/letsencrypt-routeros
```
Edit the settings file:
```sh
vim /opt/letsencrypt-routeros/letsencrypt-routeros.settings
```
Edit permissions:
```sh
chmod +x /opt/letsencrypt-routeros/letsencrypt-routeros.sh
source /opt/letsencrypt-routeros/letsencrypt-routeros.settings
```

### CertBot Let's Encrypt
Install CertBot using official manuals https://certbot.eff.org/#ubuntuxenial-other
***In the first time you will need to create and put domain TXT record manually***
```sh
certbot certonly --preferred-challenges=dns --manual -d $DOMAIN --manual-public-ip-logging-ok"
```
follow the certbot instructions 

###Usage:
```sh
letsencrypt-routeros.sh
```
or:
```sh
letsencrypt-routeros.sh [RouterOS User] [RouterOS Host] [SSH Private Key] [Domain]
```
