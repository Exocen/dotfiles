#!/bin/bash
certbot certonly -n --keep --standalone --register-unsafely-without-email --agree-tos -d [DOMAIN]

service postfix restart
service dovecot restart
service opendkim restart

(crontab -l 2>/dev/null; echo "@weekly certbot renew") | crontab -
cron -f
