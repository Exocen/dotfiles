#!/bin/bash

yaourt -Sy postfix
sudo /bin/cp /etc/postfix/main.conf
sudo /bin/cp /etc/postfix/master.cf
# openssl dhparam -out /etc/postfix/dhparam.pem 2048 # si aucun ssl
sudo postalias /etc/postfix/aliases

# cp .forward ?

yaourt -Sy python-postfix-policyd-spf opendkim

sudo /bin/cp /etc/opendkim/opendkim.conf
sudo opendkim-genkey -r -s myselector --directory=/etc/opendkim/ -d exocen.com
# cp /etc/postfix/virtual
# nom@exocen.com mail
# postmap /etc/postfix/virtual
# cat /etc/opendkim/myselector.txt
sudo systemctl enable postfix opendkim
sudo systemctl start postfix opendkim

