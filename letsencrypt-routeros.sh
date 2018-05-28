#!/bin/bash
CONFIG_FILE=letsencrypt-routeros.settings

if [[ -z $1 ]] || [[ -z $2 ]] || [[ -z $3 ]] || [[ -z $4 ]] || [[ -z $5 ]]; then
        echo -e "Usage: $0 or $0 [RouterOS User] [RouterOS Host] [SSH Port] [SSH Private Key] [Domain]\n"
        source $CONFIG_FILE
else
        ROUTEROS_USER=$1
        ROUTEROS_HOST=$2
        ROUTEROS_SSH_PORT=$3
        ROUTEROS_PRIVATE_KEY=$4
        DOMAIN=$5
fi

if [[ -z $ROUTEROS_USER ]] || [[ -z $ROUTEROS_HOST ]] || [[ -z $ROUTEROS_SSH_PORT ]] || [[ -z $ROUTEROS_PRIVATE_KEY ]] || [[ -z $DOMAIN ]]; then
        echo "Check the config file $CONFIG_FILE or start with params: $0 [RouterOS User] [RouterOS Host] [SSH Port] [SSH Private Key] [Domain]"
        echo "Please avoid spaces"
        exit 1
fi

CERTIFICATE=/etc/letsencrypt/live/$DOMAIN/cert.pem
KEY=/etc/letsencrypt/live/$DOMAIN/privkey.pem

#Create alias for RouterOS command
routeros="ssh -i $ROUTEROS_PRIVATE_KEY $ROUTEROS_USER@$ROUTEROS_HOST -p $ROUTEROS_SSH_PORT"

#Check connection to RouterOS
$routeros /system resource print
RESULT=$?

if [[ ! $RESULT == 0 ]]; then
        echo -e "\nError in: $routeros"
        echo "More info: https://wiki.mikrotik.com/wiki/Use_SSH_to_execute_commands_(DSA_key_login)"
        exit 1
else
        echo -e "\nConnection to RouterOS Successful!\n" 
fi

if [ ! -f $CERTIFICATE ] && [ ! -f $KEY ]; then
        echo -e "\nFile(s) not found:\n$CERTIFICATE\n$KEY\n"
        echo -e "Please use CertBot Let'sEncrypt:"
        echo "============================"
        echo "certbot certonly --preferred-challenges=dns --manual -d $DOMAIN --manual-public-ip-logging-ok"
        echo "or (for wildcard certificate):"
        echo "certbot certonly --preferred-challenges=dns --manual -d *.$DOMAIN --manual-public-ip-logging-ok --server https://acme-v02.api.letsencrypt.org/directory"
        echo "==========================="
        echo -e "and follow instructions from CertBot\n"
        exit 1
fi

# Remove previous certificate
$routeros /certificate remove [find name=$DOMAIN.pem_0]

# Create Certificate
# Delete Certificate file if the file exist on RouterOS
$routeros /file remove $DOMAIN.pem > /dev/null
# Upload Certificate to RouterOS
scp -q -P $ROUTEROS_SSH_PORT -i "$ROUTEROS_PRIVATE_KEY" "$CERTIFICATE" "$ROUTEROS_USER"@"$ROUTEROS_HOST":"$DOMAIN.pem"
sleep 2
# Import Certificate file
$routeros /certificate import file-name=$DOMAIN.pem passphrase=\"\"
# Delete Certificate file after import
$routeros /file remove $DOMAIN.pem

# Create Key
# Delete Certificate file if the file exist on RouterOS
$routeros /file remove $KEY.key > /dev/null
# Upload Key to RouterOS
scp -q -P $ROUTEROS_SSH_PORT -i "$ROUTEROS_PRIVATE_KEY" "$KEY" "$ROUTEROS_USER"@"$ROUTEROS_HOST":"$DOMAIN.key"
sleep 2
# Import Key file
$routeros /certificate import file-name=$DOMAIN.key passphrase=\"\"
# Delete Certificate file after import
$routeros /file remove $DOMAIN.key

# Setup Certificate to SSTP Server
$routeros /interface sstp-server server set certificate=$DOMAIN.pem_0

exit 0
