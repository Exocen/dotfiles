#!/bin/bash

cp -rn /pre_base/* /post_base/
chown opendkim:opendkim /post_base/mail.private

certbot certonly -n --keep --standalone --register-unsafely-without-email --agree-tos -d [DOMAIN]

service syslog-ng restart
service postfix restart
service dovecot restart
service opendkim restart

(crontab -l 2>/dev/null; echo "@weekly certbot renew") | crontab -
cron -f
