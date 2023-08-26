#!/bin/bash

if [ `id -u` -ne 0 ]; then
    echo "Must be run as root"
    exit 1
fi
fail2ban-client -V &>/dev/null
if  [ $? != 0 ]; then
    echo "fail2ban must be installed"
    exit 1
fi

cd $(dirname "$0")

cp -fr logrotate_docker /etc/logrotate.d/
cp -fr filter/* /etc/fail2ban/filter.d/
cp -fr jail/* /etc/fail2ban/jail.d/
mkdir -p /var/log/docker/mail_server
mkdir -p /var/log/docker/vaultwarden
touch /var/log/docker/mail_server/dovecot.log
touch /var/log/docker/mail_server/mail.log
touch /var/log/docker/vaultwarden/vaultwarden.log

systemctl restart fail2ban
