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
TMP_DIR=$(mktemp -d)

echo "Removing Dovecot $USERNAME configuration..."
grep -v "^$ADDRESS:" $BASEDIR/[DOMAIN]/shadow > $TMP_DIR/shadow ; mv -f $TMP_DIR/shadow $BASEDIR/[DOMAIN]/shadow
grep -v "^$ADDRESS::5000:5000::$BASEDIR/[DOMAIN]/$ADDRESS" $BASEDIR/[DOMAIN]/passwd > $TMP_DIR/passwd ; mv -f $TMP_DIR/passwd $BASEDIR/[DOMAIN]/passwd
chown vmail:vmail $BASEDIR/[DOMAIN]/passwd && chmod 775 $BASEDIR/[DOMAIN]/passwd
chown vmail:vmail $BASEDIR/[DOMAIN]/shadow && chmod 775 $BASEDIR/[DOMAIN]/shadow

echo "Removing Postfix $USERNAME configuration..."
grep -v "^$ADDRESS\s" /post_base/vmailbox > $TMP_DIR/vmailbox ; mv -f $TMP_DIR/vmailbox /post_base/vmailbox
postmap /post_base/vmailbox

echo "Removing $USERNAME mailbox"
rm -rf $BASEDIR/[DOMAIN]/$USERNAME

echo "$ADDRESS removed"

rm -rf $TMP_DIR
