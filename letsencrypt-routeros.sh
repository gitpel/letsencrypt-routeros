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

echo ""
echo "Updating certificate for $DOMAIN"
echo "  Using certificate $CERTIFICATE"
echo "  User private key $KEY"

#Create alias for RouterOS command
routeros="ssh -i $ROUTEROS_PRIVATE_KEY $ROUTEROS_USER@$ROUTEROS_HOST -p $ROUTEROS_SSH_PORT"

echo ""
echo "Checking connection to RouterOS"

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

# Set up variables to remove erros
DOMAIN_INSTALLED_CERT_FILE=$DOMAIN.pem_0
DOMAIN_CERT_FILE=$DOMAIN.pem
DOMAIN_KEY_FILE=$DOMAIN.key

# Remove previous certificate
echo "Removing old certificate from installed certificates: $DOMAIN_INSTALLED_CERT_FILE"
$routeros /certificate remove [find name=$DOMAIN_INSTALLED_CERT_FILE]

echo ""
echo "Handling new certificate file"
# Create Certificate
# Delete Certificate file if the file exist on RouterOS
echo "  Deleting any old copy of certificate file from disk: $DOMAIN_CERT_FILE"
$routeros /file remove $DOMAIN_CERT_FILE > /dev/null
# Upload Certificate to RouterOS
echo "  Uploading new domain certificate file to router: $CERTIFICATE"
scp -q -P $ROUTEROS_SSH_PORT -i "$ROUTEROS_PRIVATE_KEY" "$CERTIFICATE" "$ROUTEROS_USER"@"$ROUTEROS_HOST":"$DOMAIN_CERT_FILE"
sleep 2
# Import Certificate file
echo "  Importing new certificate file to router certificates"
$routeros /certificate import file-name=$DOMAIN_CERT_FILE passphrase=\"\"
# Delete Certificate file after import
echo "  Deleting any new copy of certificate file from disk: $DOMAIN_CERT_FILE"
$routeros /file remove $DOMAIN_CERT_FILE

echo ""
echo "Handling new key file"
# Create Key
# Delete Certificate file if the file exist on RouterOS
echo "  Deleting any old copy of key file from disk: $DOMAIN_KEY_FILE"
$routeros /file remove $DOMAIN_KEY_FILE > /dev/null
# Upload Key to RouterOS
echo "  Uploading new domain key file to router: $KEY"
scp -q -P $ROUTEROS_SSH_PORT -i "$ROUTEROS_PRIVATE_KEY" "$KEY" "$ROUTEROS_USER"@"$ROUTEROS_HOST":"$DOMAIN_KEY_FILE"
sleep 2
# Import Key file
echo "  Importing new key file to router certificates"
$routeros /certificate import file-name=$DOMAIN_KEY_FILE passphrase=\"\"
# Delete Certificate file after import
echo "  Deleting any new copy of key file from disk: $DOMAIN_KEY_FILE"
$routeros /file remove $DOMAIN_KEY_FILE

echo ""

# Setup Certificate to SSTP Server
echo "Updating SSTP Server to use $DOMAIN_INSTALLED_CERT_FILE"
$routeros /interface sstp-server server set certificate=$DOMAIN_INSTALLED_CERT_FILE

# Setup Certificate to SSL
echo "Updating HTTPS Server to use $DOMAIN_INSTALLED_CERT_FILE"
$routeros /ip service set www-ssl certificate=$DOMAIN_INSTALLED_CERT_FILE

echo "Updating API SSL Server to use $DOMAIN_INSTALLED_CERT_FILE"
$routeros /ip service set api-ssl certificate=$DOMAIN_INSTALLED_CERT_FILE

exit 0
