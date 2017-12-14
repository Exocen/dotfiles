#!/bin/bash

sudo hostnamectl set-hostname HOSTNAME
yaourt -Sy postfix --noconfirm
sudo /bin/cp main.cf /etc/postfix/main.cf -f
sudo /bin/cp master.cf /etc/postfix/master.cf -f
# openssl dhparam -out /etc/postfix/dhparam.pem 2048 # si aucun ssl
sudo postalias /etc/postfix/aliases

# cp .forward ?

yaourt -Sy python-postfix-policyd-spf opendkim --noconfirm

sudo /bin/cp opendkim.conf /etc/opendkim/opendkim.conf -f
sudo opendkim-genkey -r -s myselector --directory=/etc/opendkim/ -d HOSTNAME
# cp /etc/postfix/virtual6
# nom@HOSTNAME mail
# postmap /etc/postfix/virtual
# cat /etc/opendkim/myselector.txt
sudo systemctl enable postfix opendkim
sudo systemctl start postfix opendkim

