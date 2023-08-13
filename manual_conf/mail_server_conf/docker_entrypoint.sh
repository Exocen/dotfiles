#!/bin/bash
certbot certonly -n --keep --standalone --register-unsafely-without-email --agree-tos -d [DOMAIN]

service postfix stop
service dovecot restart
service opendkim restart
(crontab -l 2>/dev/null; echo "@weekly certbot renew") | crontab -
service crond restart

postfix start-fg
