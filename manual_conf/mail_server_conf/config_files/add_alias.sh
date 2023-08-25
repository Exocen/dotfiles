#!/bin/bash
if [ `id -u` -ne 0 ]; then
    echo "Must be run as root"
    exit 1
fi
if [ "$#" -ne 2 ]
then
    echo "Usage: $0 ALIAS EMAIL"
    exit 1
fi

echo "$1 $2" >> /post_base/virtual_alias
postmap /post_base/virtual_alias
systemctl reload postfix
echo "$1 to $2 added"
