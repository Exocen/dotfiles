#!/bin/bash
certbot certonly -n --keep --standalone --register-unsafely-without-email --agree-tos -d [DOMAIN]

service postfix stop
service dovecot restart
service opendkim restart

postfix start-fg
