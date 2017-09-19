#!/bin/bash

git clone https://github.com/exocen/hangoutsbot ~/hangoutsbot

apt install nginx letencrypt -y
mkdir -p /etc/nginx/ssl
touch /etc/nginx/ssl/ticket.key
openssl rand 48 >> /etc/nginx/ssl/ticket.key
openssl dhparam -out /etc/nginx/ssl/dhparam4.pem 4096

# certbot certonly --agree-tos --rsa-key-size 4096 --register-unsafely-without-email --webroot --webroot-path /var/www/html -d mondomaine.fr
# crontab -e
# 30 2 * * * certbot renew >> /var/log/letsencrypt/renewal.log

# Local Variables:
# mode: Shell-script
# coding: mule-utf-8
# End:
