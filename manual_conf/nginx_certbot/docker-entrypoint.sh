#!/bin/bash


certbot certificates | grep 'vw.[DOMAIN]\|www.[DOMAIN]'
RESULT=$?
if [ $RESULT -eq 1 ]; then
    certbot --nginx --keep-until-expiring --expand --register-unsafely-without-email --agree-tos -d [DOMAIN] -d vw.[DOMAIN] -d www.[DOMAIN] &>/var/log/certbot.log || (echo "certbot failed exiting..." && exit 1)
fi

cp -fr /root/nginx.conf /etc/nginx/
service syslog-ng restart

(echo "@daily /usr/bin/certbot renew --nginx &>/var/log/certbot.log") | crontab -
service cron restart

mkdir -p /var/log/nginx
nginx -g 'daemon off;'
