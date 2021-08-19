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
  sudo apt-get install postfix postfix-mysql dovecot-core dovecot-imapd dovecot-pop3d dovecot-lmtpd dovecot-mysql opendkim opendkim-tools mariadb-server certbot
  sudo certbot certonly --dry-run --standalone --register-unsafely-without-email --agree-tos -d $DOMAIN
}


#debian 9+
#todo hostname= [DOMAIN]
# pssserv = randomize
# sudo apt-get install postfix postfix-mysql dovecot-core dovecot-imapd dovecot-pop3d dovecot-lmtpd dovecot-mysql opendkim opendkim-tools mariadb-server certbot sendmail
#
# sudo certbot certonly --standalone --register-unsafely-without-email --agree-tos -d [DOMAIN]

#todo can no interaction ?
# sudo mysql_secure_installation

# #todo bash me
# sudo mysql -u root -p

# CREATE DATABASE mailserver;
# CREATE USER 'mailuser'@'127.0.0.1' IDENTIFIED BY '[PASSSERV]';
# GRANT SELECT ON mailserver.* TO 'mailuser'@'127.0.0.1';
# FLUSH PRIVILEGES;
# USE mailserver;
# CREATE TABLE `virtual_users` (
#   `id` int(11) NOT NULL auto_increment,
#   `domain_id` int(11) NOT NULL,
#   `password` varchar(106) NOT NULL,
#   `email` varchar(100) NOT NULL,
#   PRIMARY KEY (`id`),
#   UNIQUE KEY `email` (`email`),
#   FOREIGN KEY (domain_id) REFERENCES virtual_domains(id) ON DELETE CASCADE
# ) ENGINE=InnoDB DEFAULT CHARSET=utf8;

# CREATE TABLE `virtual_aliases` (
#   `id` int(11) NOT NULL auto_increment,
#   `domain_id` int(11) NOT NULL,
#   `source` varchar(100) NOT NULL,
#   `destination` varchar(100) NOT NULL,
#   PRIMARY KEY (`id`),
#   FOREIGN KEY (domain_id) REFERENCES virtual_domains(id) ON DELETE CASCADE
# ) ENGINE=InnoDB DEFAULT CHARSET=utf8;

# INSERT INTO mailserver.virtual_domains (name) VALUES ('[DOMAIN]');

# # new email
# sudo mysql -u root -p
# INSERT INTO mailserver.virtual_users (domain_id, password , email) VALUES ('1', TO_BASE64(UNHEX(SHA2('password', 512))), 'user@example.com');
# #new alias
# INSERT INTO mailserver.virtual_aliases (domain_id, source, destination) VALUES ('1', 'alias@example.com', 'user@example.com');

main

# Local Variables:
# mode: Shell-script
# coding: mule-utf-8
# End:
