#!/bin/bash

mkdir -p /var/log/nginx /var/log/letsencrypt
cp -fr /root/fifo-nginx.conf /etc/nginx/nginx.conf

if /usr/bin/certbot certificates | grep '[DOMAIN]\|*.[DOMAIN]' &>/dev/null; then
    /usr/bin/certbot --nginx --keep-until-expiring --expand --register-unsafely-without-email --agree-tos --logs-dir $LOG_DIR -q -d [DOMAIN] -d git.[DOMAIN] -d mail.[DOMAIN] -d status.[DOMAIN] -d www.[DOMAIN] -d vw.[DOMAIN]
    if /usr/bin/certbot certificates | grep '[DOMAIN]\|*.[DOMAIN]' &>/dev/null; then
        echo "certbot failed exiting..."
        exit 1
    fi
fi

cp -fr /root/nginx.conf /etc/nginx/nginx.conf
pkill 'nginx'
nginx -g 'daemon off;'
