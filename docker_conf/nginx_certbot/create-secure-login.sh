#!/bin/bash

if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: ./script user password"
    exit 1
fi

mkdir -p /docker-data/nginx
printf "$1:$(openssl passwd -6 $2)\n" >> /docker-data/nginx/htpasswd
