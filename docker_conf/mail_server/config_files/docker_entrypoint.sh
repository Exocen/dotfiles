#!/bin/bash

cp /etc/resolv.conf /var/spool/postfix/etc/resolv.conf
mkdir -p /post_base/vhosts/[DOMAIN]
cp -rn /pre_base/* /post_base/
chown -R vmail:vmail /post_base/vhosts
chown opendkim:opendkim /post_base/mail.private

service syslog-ng start
service dovecot start
service opendkim start

postfix start-fg
