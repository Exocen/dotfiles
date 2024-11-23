#!/bin/bash

cp /etc/resolv.conf /var/spool/postfix/etc/resolv.conf
mkdir -p /post_base/vhosts/[DOMAIN]
cp -rn /pre_base/* /post_base/
chown -R vmail:vmail /post_base/vhosts
chown opendkim:opendkim /post_base/mail.private

rc-service syslog-ng start
rc-service dovecot start
rc-service opendkim start
rc-service postfix start

tail -F /var/log/dovecot.log &
tail -F /var/log/mail.log
