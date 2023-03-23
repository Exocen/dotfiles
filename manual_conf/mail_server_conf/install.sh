#!/bin/bash

WOS=''
DOMAIN=$1
TMP_CONF=$(mktemp -d)

function main() {
    detectOS
    if [ "$WOS" = "debian" ]; then
        pack_install
        generate_conf
        #TODO dry-run :P
        certbot certonly --standalone --register-unsafely-without-email --dry-run --agree-tos -d $DOMAIN
        put_conf
    else
        echo "Must be run on Debian"
    fi
}

function generate_conf() {
    hostnamectl set-hostname $DOMAIN
    cp -r dovecot.conf opendkim postfix opendkim.conf $TMP_CONF
    cd $TMP_CONF
    find . -type f -print0 | xargs -0 sed -i 's/\[DOMAIN\]/'$DOMAIN'/g'
}

function detectOS() {
    if [ -f /etc/lsb-release ]; then
        WOS=$(cat /etc/lsb-release | grep DISTRIB_ID | sed 's/^.*=//' | tr -dc '[:alnum:]\n\r' | tr '[:upper:]' '[:lower:]')
    elif [ -f /etc/os-release ]; then
        WOS=$(cat /etc/os-release | grep '^ID=.*' | sed 's/^.*=//'  | tr -dc '[:alnum:]\n\r' | tr '[:upper:]' '[:lower:]')
    elif [ -f /etc/redhat-release ]; then
        WOS="fedora"
    elif [ -f /etc/centos-release ]; then
        WOS="centOS"
    elif [ -f /etc/debian_version ]; then
        WOS="debian"
    elif [ -f /etc/arch-release ]; then
        WOS="arch"
    else
        WOS="WTH?"
    fi
}

function pack_install() {
    sudo apt-get update -y && sudo apt-get upgrade -y
    sudo apt-get install -y postfix dovecot-core dovecot-imapd dovecot-lmtpd opendkim opendkim-tools certbot
}

function put_conf() {
    # Post-generate_conf
    cp -fr $TMP_CONF/postfix/* /etc/postfix/
    chmod -R o-rwx /etc/postfix

    touch /etc/postfix/vmailbox
    postmap /etc/postfix/vmailbox
    touch /etc/postfix/virtual_alias
    postmap /etc/postfix/virtual_alias

    cp -fr $TMP_CONF/dovecot.conf /etc/dovecot/
    mkdir -p /var/mail/vhosts/$DOMAIN
    groupadd -g 5000 vmail
    useradd -g vmail -u 5000 vmail -d /var/mail
    chown -R vmail:vmail /var/mail
    chown -R vmail:dovecot /etc/dovecot
    chmod -R o-rwx /etc/dovecot

    cp -fr $TMP_CONF/opendkim.conf /etc/
    mkdir -p /etc/opendkim/keys/$DOMAIN
    cp -fr $TMP_CONF/opendkim/* /etc/opendkim/
    opendkim-genkey -s mail -d $DOMAIN -D /etc/opendkim/keys/$DOMAIN
    chown opendkim:opendkim /etc/opendkim/keys/$DOMAIN/mail.private
    chmod 0400 /etc/opendkim/keys/$DOMAIN/mail.private

    systemctl restart postfix dovecot opendkim
    echo "Opendkim key:"
    cat /etc/opendkim/keys/$DOMAIN/*.txt
}

if [ `id -u` -ne 0 ]; then
    echo "Must be run as root"
else
    if [ -z "$1" ]; then
        echo "No domain supplied"
    else
        main
    fi
fi

cd "${0%/*}"
rm -rf $TMP_CONF

# Local Variables:
# mode: Shell-script
# coding: mule-utf-8
# End:
