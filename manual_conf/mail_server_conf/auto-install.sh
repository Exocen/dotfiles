#!/bin/bash
# cd script location
WOS=''
DOMAIN=''
PASSSERV=`date +%s | sha256sum | base64 | head -c 32 ; echo`

function main {
    detectOS
    if [ "$WOS" = "Debian" ]; then
        echo "Hostname ? :"
        read hostname
        echo $hostname" ? (y/N)"
        read answer
        if [ "$answer" == "Y" ] || [ "$answer" == "y" ] || [ "$answer" == "YES" ] || [ "$answer" == "yes" ];then
            echo 'Pre-install.....'
            DOMAIN=$hostname
            pack_install
            generate_conf
        else
            echo 'Cancel'
        fi
    else
        echo "Must be ran on Debian"
    fi

}

function generate_conf {
    cd "${0%/*}"
    sudo hostnamectl set-hostname $DOMAIN
    tmpD=`mktemp -d`
    cp -r dovecot opendkim postfix opendkim.conf $tmpD
    cd $tmpD
    find . -type f -print0 | xargs -0 sed -i 's/\[DOMAIN\]/'$DOMAIN'/g'
    find . -type f -print0 | xargs -0 sed -i 's/\[PASSSERV\]/'$PASSSERV'/g'
}


function detectOS {
    if [ -f /etc/lsb-release ]; then
        OS=$(cat /etc/lsb-release | grep DISTRIB_ID | sed 's/^.*=//')
        VERSION=$(cat /etc/lsb-release | grep DISTRIB_RELEASE | sed 's/^.*=//')
        if [ "$OS" = "Ubuntu" ] || [ "$OS" = "Debian" ] || [ "$OS" = "Arch" ];then
            WOS="$OS"
        fi
    elif [ -f /etc/redhat-release ]; then
        WOS="Fedora"
    elif [ -f /etc/centos-release ]; then
        WOS="CentOS"
    elif [ -f /etc/debian_version ]; then
        WOS="Debian"
    elif [ -f /etc/arch-release ]; then
        WOS="Arch"
    else
        WOS="WTH?"
    fi
}

function pack_install {
    sudo apt-get update -y && sudo apt-get upgrade -y
    sudo apt-get install -y postfix postfix-mysql dovecot-core dovecot-imapd dovecot-pop3d dovecot-lmtpd dovecot-mysql opendkim opendkim-tools mariadb-server certbot
    #TODO dry-run here
    sudo certbot certonly --dry-run --standalone --register-unsafely-without-email --agree-tos -d $DOMAIN
    sudo mysql_secure_installation
    build_database
    put_conf
}

function mysql_exec {
    sudo mysql -u root -e "$1"
}

function build_database {
    mysql_exec "CREATE DATABASE mailserver;
    CREATE USER 'mailuser'@'127.0.0.1' IDENTIFIED BY '$PASSSERV';
    GRANT SELECT ON mailserver.* TO 'mailuser'@'127.0.0.1';
    FLUSH PRIVILEGES;
    USE mailserver;
    CREATE TABLE \`virtual_domains\` (
    \`id\` int(11) NOT NULL auto_increment,
    \`name\` varchar(50) NOT NULL,
    PRIMARY KEY (\`id\`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8;
    CREATE TABLE \`virtual_users\` (
    \`id\` int(11) NOT NULL auto_increment,
    \`domain_id\` int(11) NOT NULL,
    \`password\` varchar(106) NOT NULL,
    \`email\` varchar(100) NOT NULL,
    PRIMARY KEY (\`id\`),
    UNIQUE KEY \`email\` (\`email\`),
    FOREIGN KEY (domain_id) REFERENCES virtual_domains(id) ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8;
    CREATE TABLE \`virtual_aliases\` (
    \`id\` int(11) NOT NULL auto_increment,
    \`domain_id\` int(11) NOT NULL,
    \`source\` varchar(100) NOT NULL,
    \`destination\` varchar(100) NOT NULL,
    PRIMARY KEY (\`id\`),
    FOREIGN KEY (domain_id) REFERENCES virtual_domains(id) ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8;"
    mysql_exec "INSERT INTO mailserver.virtual_domains (name) VALUES ('$DOMAIN');"
}

function put_conf {
    #after generate_conf (no cd)
    sudo cp -fr postfix/* /etc/postfix/
    sudo chmod -R o-rwx /etc/postfix

    sudo cp -fr dovecot/* /etc/dovecot/
    sudo mkdir -p /var/mail/vhosts/$DOMAIN
    sudo groupadd -g 5000 vmail
    sudo useradd -g vmail -u 5000 vmail -d /var/mail
    sudo chown -R vmail:vmail /var/mail
    sudo chown -R vmail:dovecot /etc/dovecot
    sudo chmod -R o-rwx /etc/dovecot

    sudo cp -fr opendkim.conf /etc/opendkim.conf
    sudo mkdir -p /etc/opendkim
    sudo cp -fr opendkim/* /etc/opendkim/
    sudo opendkim-genkey -s mail -d $DOMAIN -D /etc/opendkim/keys/$DOMAIN
    sudo chown opendkim:opendkim /etc/opendkim/keys/$DOMAIN/mail.private
    sudo chmod 0400 /etc/opendkim/keys/$DOMAIN/mail.private

    sudo systemctl restart postfix dovecot opendkim
    echo "opendkim key: "
    sudo cat /etc/opendkim/keys/$DOMAIN
}

main

# Local Variables:
# mode: Shell-script
# coding: mule-utf-8
# End:
