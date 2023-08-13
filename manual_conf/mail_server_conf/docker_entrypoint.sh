#!/bin/bash
certbot certonly -n --keep --standalone --register-unsafely-without-email --agree-tos -d $1

service rsyslog restart
service postfix restart
service dovecot restart
service opendkim restart

tail -f /etc/mail.log
