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

cp -fr filter/* /etc/fail2ban/filter.d/
cp -fr jail/* /etc/fail2ban/jail.d/

systemctl restart fail2ban
