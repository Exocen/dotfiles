#!/bin/bash
if [ `id -u` -ne 0 ]; then
    echo "Must be run as root"
    exit 1
fi
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 USERNAME"
    exit 1
fi

USERNAME=$1
ADDRESS="$USERNAME@[DOMAIN]"
PASSWD=$2
BASEDIR=/post_base/vhosts

echo $ADDRESS":"$(doveadm pw) >> $BASEDIR/[DOMAIN]/shadow

if [ $? -eq 0 ]
then
    echo "Adding Dovecot $USERNAME configuration..."
    echo $ADDRESS::5000:5000::$BASEDIR/[DOMAIN]/$ADDRESS>> $BASEDIR/[DOMAIN]/passwd
    chown vmail:vmail $BASEDIR/[DOMAIN]/passwd && chmod 775 $BASEDIR/[DOMAIN]/passwd
    chown vmail:vmail $BASEDIR/[DOMAIN]/shadow && chmod 775 $BASEDIR/[DOMAIN]/shadow

    echo "Adding Postfix $USERNAME configuration..."
    echo $ADDRESS [DOMAIN]/$USERNAME/ >> /post_base/vmailbox
    postmap /post_base/vmailbox

    echo "$ADDRESS added"
else
    echo "No user created, exiting..."
fi
