#!/bin/bash

sudo hostnamectl set-hostname HOSTNAME
yaourt -Sy postfix python-postfix-policyd-spf opendkim --noconfirm
sudo /bin/cp main.cf /etc/postfix/main.cf -f
sudo /bin/cp master.cf /etc/postfix/master.cf -f
sudo postalias /etc/postfix/aliases
# openssl dhparam -out /etc/postfix/dhparam.pem 2048 # if no ssl

sudo /bin/cp opendkim.conf /etc/opendkim/opendkim.conf -f
sudo opendkim-genkey -r -s myselector --directory=/etc/opendkim/ -d HOSTNAME

sudo systemctl enable postfix opendkim
sudo systemctl start postfix opendkim

# DKIM selector value : 
# cat /etc/opendkim/myselector.txt

# Mail redirection :
# add "name@HOSTNAME mail-to-go" to end of /etc/postfix/virtual
# Ex bob@bob.com bob@gmail.com
# then
# postmap /etc/postfix/virtual
