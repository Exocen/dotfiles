#!/bin/bash

function main(){

    docker build --build-arg DOMAIN=$1 -t mailserv . && \
\
 \   docker run -v /etc/letsencrypt/:/etc/letsencrypt/ -v /post_base:/post_base -v /var/mail/vhosts:/var/mail/vhosts -p 25:25 -p 587:587 -p 465:465 -p 143:143 -p 993:993 -p 80:80 --name mailserver -d --restart unless-stopped mailserv:latest

}

if [ `id -u` -ne 0 ]; then
    echo "Must be run as root"
else
    if [ -z "$1" ]; then
        echo "No domain supplied"
    else
        main
    fi
fi

