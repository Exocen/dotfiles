#!/bin/bash

cp /etc/resolv.conf /var/spool/postfix/etc/resolv.conf
mkdir -p /post_base/vhosts/[DOMAIN]
cp -rn /pre_base/* /post_base/
chown -R vmail:vmail /post_base/vhosts
chown opendkim:opendkim /post_base/mail.private

service syslog-ng restart
service dovecot restart
service opendkim restart
service postfix restart

tail -F /var/log/dovecot.log &
tail -F /var/log/mail.log
