#!/bin/bash

git clone https://github.com/exocen/hangoutsbot ~/hangoutsbot

# Append the appropriate stanza to /etc/apt/sources.list.

# deb http://nginx.org/packages/debian/ squeeze nginx
# deb-src http://nginx.org/packages/debian/ squeeze nginx


wget https://dl.eff.org/certbot-auto
chmod a+x certbot-auto
openssl dhparam -out /etc/nginx/dhparam4.pem 4096

# certbot --nginx --agree-tos --rsa-key-size 4096 --register-unsafely-without-email
# or in /etc/letsencrypt/cli.ini
# crontab -e
# 30 2 * * * certbot renew >> /var/log/letsencrypt/renewal.log

# Local Variables:
# mode: Shell-script
# coding: mule-utf-8
# End:
