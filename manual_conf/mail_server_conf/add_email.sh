#!/bin/bash
if [ `id -u` -ne 0 ]; then
    echo "Must be run as root"
    exit 1
fi
if [ ! -n "$2" ]
then
    echo "Usage: $0 EMAIL PASSWORD"
    exit 1
fi

USERNAME=$(echo "$1" | cut -f1 -d@)
DOMAIN=$(echo "$1" | cut -f2 -d@)
ADDRESS=$1
PASSWD=$2
BASEDIR=/var/mail/vhosts

echo "Adding Postfix user configuration..."
echo $ADDRESS $DOMAIN/$USERNAME/ >> /etc/postfix/vmailbox
postmap /etc/postfix/vmailbox

if [ $? -eq 0 ]
then
    echo "Adding Dovecot user configuration..."
    echo $ADDRESS::5000:5000::$BASEDIR/$DOMAIN/$ADDRESS>> $BASEDIR/$DOMAIN/passwd
    echo $ADDRESS":"$(doveadm pw -p $PASSWD) >> $BASEDIR/$DOMAIN/shadow
    chown vmail:vmail $BASEDIR/$DOMAIN/passwd && chmod 775 $BASEDIR/$DOMAIN/passwd
    chown vmail:vmail $BASEDIR/$DOMAIN/shadow && chmod 775 $BASEDIR/$DOMAIN/shadow
    systemctl reload postfix
    echo "$1 added"
fi
