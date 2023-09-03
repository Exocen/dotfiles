#!/bin/bash

mkdir -p /var/log/nginx
/usr/bin/certbot certificates | grep 'vw.[DOMAIN]\|www.[DOMAIN]'
RESULT=$?
if [ $RESULT -eq 1 ]; then
    /usr/bin/certbot --nginx --keep-until-expiring --expand --register-unsafely-without-email --agree-tos -d [DOMAIN] -d vw.[DOMAIN] -d www.[DOMAIN] || (echo "certbot failed exiting..." && exit 1)
fi

service cron restart

cp -fr /root/nginx.conf /etc/nginx/
nginx -g 'daemon off;'
