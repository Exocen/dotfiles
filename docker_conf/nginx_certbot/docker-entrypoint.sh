#!/bin/bash
CERTBOT_RENEW_DATE='1 day'

certbot_renew(){
    while true; do
        echo "Starting Certbot renew..."
        /usr/bin/certbot renew --nginx && echo "Certbot renew succeded"
        sleep $(( $(date -d "$CERTBOT_RENEW_DATE" +%s) - $(date +%s) ))
    done
}

mkdir -p /var/log/nginx
mkdir -p /var/log/letsencrypt

/usr/bin/certbot certificates | grep '[DOMAIN]\|*.[DOMAIN]' &>/dev/null
RESULT=$?
if [ $RESULT -ne 0 ]; then
    #TODO check dat
    #/usr/bin/certbot --nginx --keep-until-expiring --expand --register-unsafely-without-email --agree-tos -d [DOMAIN] -d vw.[DOMAIN] -d git.[DOMAIN] -d www.[DOMAIN] -d mail.[DOMAIN]
    /usr/bin/certbot --nginx --keep-until-expiring --expand --register-unsafely-without-email --agree-tos -d [DOMAIN] -d *.[DOMAIN]
    if [ $? -ne 0 ]; then
        echo "certbot failed exiting..."
        exit 1
    fi
fi

cp -fr /root/nginx.conf /etc/nginx/
certbot_renew &
sleep 1m
service nginx stop &>/dev/null
nginx -g 'daemon off;'
