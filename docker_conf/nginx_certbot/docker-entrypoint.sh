#!/bin/bash

/usr/bin/certbot certificates --max-log-backups 0 | grep 'vw.[DOMAIN]\|www.[DOMAIN]'
RESULT=$?
if [ $RESULT -eq 1 ]; then
    /usr/bin/certbot --nginx --keep-until-expiring --expand --register-unsafely-without-email --agree-tos -d [DOMAIN] -d vw.[DOMAIN] -d www.[DOMAIN] --max-log-backups 0 || (echo "certbot failed exiting..." && exit 1)
fi

cp -fr /root/nginx.conf /etc/nginx/
service syslog-ng restart

echo "@daily /usr/bin/certbot renew --nginx --max-log-backups 0" > /etc/cron.d/certbot
service cron restart

mkdir -p /var/log/nginx
nginx -g 'daemon off;'
