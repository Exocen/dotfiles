#!/bin/bash
CERTBOT_RENEW_DATE='1 day'

certbot_renew(){
    while true; do
        echo "Starting Certbot renew..."
        /usr/bin/certbot renew --nginx --max-log-backups 1 && echo "Certbot renew succeded"
        sleep $(( $(date -d "$CERTBOT_RENEW_DATE" +%s) - $(date +%s) ))
    done
}

mkdir -p /var/log/nginx
mkdir -p /var/log/letsencrypt

/usr/bin/certbot certificates | grep '[DOMAIN]\|*.[DOMAIN]' &>/dev/null
RESULT=$?
if [ $RESULT -ne 0 ]; then
    /usr/bin/certbot --nginx --keep-until-expiring --expand --register-unsafely-without-email --agree-tos --max-log-backups 1 -d [DOMAIN] -d git.[DOMAIN] -d mail.[DOMAIN] -d status.[DOMAIN] -d www.[DOMAIN] -d vw.[DOMAIN]
    if [ $? -ne 0 ]; then
        echo "certbot failed exiting..."
        exit 1
    fi
fi

cp -fr /root/nginx.conf /etc/nginx/
certbot_renew > /root/_certout &
tail -F /root/_certout
sleep 1m
service nginx stop &>/dev/null
nginx -g 'daemon off;'
