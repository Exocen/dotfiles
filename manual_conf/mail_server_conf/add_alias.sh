#!/bin/bash
if [ `id -u` -ne 0 ]; then
    echo "Must be run as root"
    exit 1
fi
if [ ! -n "$2" ]
then
    echo "Usage: $0 ALIAS EMAIL"
    exit 1
fi

echo "$1 $2" >> /etc/postfix/virtual_alias
postmap /etc/postfix/virtual_alias
systemctl reload postfix
echo "$1 to $2 added"
