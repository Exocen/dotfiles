#!/bin/bash

cp -rn /pre_base/* /post_base/
chown opendkim:opendkim /post_base/mail.private

service syslog-ng restart
service dovecot restart
service opendkim restart

postfix start-fg
