#!/bin/bash
certbot certonly -n --keep --standalone --register-unsafely-without-email --agree-tos -d [DOMAIN]

service rsyslog restart
service postfix restart
service dovecot restart
service opendkim restart

tail -f /etc/mail.log
