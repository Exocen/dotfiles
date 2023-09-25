#!/bin/bash

DOMAIN=$1

function main(){
    find . -type f -print0 | xargs -0 sed -i 's/\[DOMAIN\]/'$DOMAIN'/g'

    mkdir /pre_base
    mv -f postfix/* /etc/postfix/
    chmod -R o-rwx /etc/postfix
    touch /pre_base/vmailbox
    postmap /pre_base/vmailbox
    touch /pre_base/virtual_alias
    postmap /pre_base/virtual_alias
    newaliases

    mv -f dovecot.conf /etc/dovecot/
    mkdir -p /post_base/vhosts/$DOMAIN
    addgroup -g 5000 vmail
    adduser -D -G vmail -u 5000 vmail -h /var/mail
    chown -R vmail:vmail /var/mail
    chown -R vmail:dovecot /etc/dovecot
    chmod -R o-rwx /etc/dovecot

    mv -f opendkim.conf /etc/
    mkdir -p /etc/opendkim
    mv -f opendkim/* /etc/opendkim/
    opendkim-genkey -s mail -d $DOMAIN -D /pre_base
    chown opendkim:opendkim /pre_base/mail.private
    chmod 0400 /pre_base/mail.private
}


if [ -z "$1" ]; then
    echo "No domain supplied"
else
    main
fi
