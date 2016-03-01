#!/bin/bash
RED="31"
GREEN="32"
WOS=""

function makeItColorful {
    echo -e "\e[$2m$1\e[0m"
}

function is_working {
    if [ $? -eq 0 ];then
        makeItColorful "Réussite : $1" $GREEN
    else
        makeItColorful "Echec : $1" $RED
    fi
}

function detectOS {
    if [ -f /etc/lsb-release ]; then
        OS=$(cat /etc/lsb-release | grep DISTRIB_ID | sed 's/^.*=//')
        VERSION=$(cat /etc/lsb-release | grep DISTRIB_RELEASE | sed 's/^.*=//')
        if [ "$OS" = "Ubuntu" ] || [ "$OS" = "Debian" ] ;then
            WOS="$OS"
        fi
    elif [ -f /etc/redhat-release ]; then
        WOS="Fedora"
    elif [ -f /etc/centos-release ]; then
        WOS="CentOS"
    else
        WOS="WTF ?"
    fi
}

function cloneOhmyZsh {
    if [ -d ".oh-my-zsh" ]; then
	cd .oh-my-zsh
	git pull https://github.com/exocen/oh-my-zsh master
	cd ..
    else
        git clone https://github.com/exocen/oh-my-zsh .oh-my-zsh/
    fi
    is_working "Clonage de oh-my-zsh"
}

function home_ln {
    ln -sf `pwd`/$1 -t ~/ > /dev/null 2>&1
    is_working "Création de $1 sur ~"
}

function home_cp {
    unalias cp > /dev/null 2>&1
    cp -fr `pwd`/$1 ~/$1 > /dev/null 2>&1
    is_working "Copie de $1 sur ~"
    alias cp="cp -iv" > /dev/null 2>&1
}

# Faire un detectOS avant
function ins {
    all="$@" # pour fonction is_working
    echo "Installation: $all ...."
    if [ "$WOS" = "Ubuntu" ] || [ "$WOS" = "Debian" ] ;then
        sudo aptitude update -y # > /dev/null 2>&1
        sudo aptitude install $@ -y # > /dev/null 2>&1
        is_working "Installation de $all"
    elif [ "$WOS" = "Fedora" ] ;then
        sudo dnf install $@ -y #> /dev/null 2>&1
        is_working "Installation de $all"
    else
        makeItColorful "OS Inconnu" $RED
    fi
}


function postfix_install {

    ins libdb5.1 db4.8-util postfix procmail sasl2-bin libsasl2-modules libsasl2-modules-sql libgsasl7 libauthen-sasl-cyrus-perl sasl2-bin libpam-mysql
    sudo adduser postfix sasl
    sudo dpkg-reconfigure postfix
    sudo postconf -e 'smtpd_sasl_local_domain ='
    sudo  postconf -e 'smtpd_sasl_auth_enable = yes'
    sudo  postconf -e 'smtpd_sasl_security_options = noanonymous'
    sudo  postconf -e 'broken_sasl_auth_clients = yes'
    sudo   postconf -e 'smtpd_recipient_restrictions = permit_sasl_authenticated,permit_mynetworks,reject_unauth_destination'
    sudo  postconf -e 'inet_interfaces = all'
    sudo  touch /etc/postfix/sasl/smtpd.conf
    sudo su
    echo 'pwcheck_method: saslauthd' >> /etc/postfix/sasl/smtpd.conf
    echo 'mech_list: plain login' >> /etc/postfix/sasl/smtpd.conf
    exit
    sudo mkdir /etc/postfix/ssl
    cd /etc/postfix/ssl/
    sudo openssl genrsa -des3 -rand /etc/hosts -out smtpd.key 1024
    sudo openssl req -new -key smtpd.key -out smtpd.csr
    sudo  openssl x509 -req -days 3650 -in smtpd.csr -signkey smtpd.key -out smtpd.crt
    sudo openssl rsa -in smtpd.key -out smtpd.key.unencrypted
    sudo mv -f smtpd.key.unencrypted smtpd.key
    sudo chmod 600 smtpd.key
    sudo openssl req -new -x509 -extensions v3_ca -keyout cakey.pem -out cacert.pem -days 3650

    sudo postconf -e 'smtpd_tls_auth_only = no'
    sudo postconf -e 'smtp_use_tls = yes'
    sudo postconf -e 'smtpd_use_tls = yes'
    sudo postconf -e 'smtp_tls_note_starttls_offer = yes'
    sudo postconf -e 'smtpd_tls_key_file = /etc/postfix/ssl/smtpd.key'
    sudo postconf -e 'smtpd_tls_cert_file = /etc/postfix/ssl/smtpd.crt'
    sudo postconf -e 'smtpd_tls_CAfile = /etc/postfix/ssl/cacert.pem'
    sudo postconf -e 'smtpd_tls_loglevel = 1'
    sudo postconf -e 'smtpd_tls_received_header = yes'
    sudo postconf -e 'smtpd_tls_session_cache_timeout = 3600s'
    sudo postconf -e 'tls_random_source = dev:/dev/urandom'
    sudo postconf -e 'myhostname = exocen.com'



    sudo cp -f postfix_main.cf /etc/postfix/main.cf
    #make virtual stuff

    sudo mkdir -p /var/spool/postfix/var/run/saslauthd
    sudo rm -fr /var/run/saslauthd
    sudo ln -s /var/spool/postfix/var/run/saslauthd /var/run/saslauthd
    sudo chown -R root:sasl /var/spool/postfix/var/
    sudo chmod 710 /var/spool/postfix/var/run/saslauthd
    sudo adduser postfix sasl

    #Pour ce faire décommentez la ligne
    #START=yes
    #et modifiez la derniere lignz
    #OPTIONS="-c -m /var/run/saslauthd"
    #comme cela:
    #
    #OPTIONS="-m /var/spool/postfix/var/run/saslauthd"

    sudo service postfix restart

}

function make {
    detectOS
    if  [ "$1" = "p" ]
    then
        {
            postfix_install
        }
    else
        {
            home_ln .emacs
            cloneOhmyZsh
            home_ln .zshrc
            home_cp .oh-my-zsh/
            home_cp .oh-my-zsh/.*
            ins emacs vlc git htop mosh tree zsh
	    chsh -s /usr/bin/zsh
            if  [ "$1" = "f" ]
            then
                {
                    home_ln .i3
                    ins comix clementine texlive texlive-latex java-1.8.0-openjdk-devel ruby-devel i3 nitrogen numlockx i3lock i3status xbacklight fontawesome-fonts-web sysstat network-manager-applet acpi
                }
            else
                {
                    echo "Argument 'f' pour installation complète"
                }
            fi

            echo "Argument 'p' pour installation postfix"
        }
    fi




}
make $1
exit 0

# Local Variables:
# mode: Shell-script
# coding: mule-utf-8
# End:
