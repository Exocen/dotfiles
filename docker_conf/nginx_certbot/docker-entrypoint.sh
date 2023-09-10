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

/usr/bin/certbot certificates | grep 'vw.[DOMAIN]\|www.[DOMAIN]' &>/dev/null
RESULT=$?
if [ $RESULT -eq 1 ]; then
    /usr/bin/certbot --nginx --keep-until-expiring --expand --register-unsafely-without-email --agree-tos -d [DOMAIN] -d vw.[DOMAIN] -d www.[DOMAIN] || (echo "certbot failed exiting..." && exit 1)
fi

cp -fr /root/nginx.conf /etc/nginx/
certbot_renew &
nginx -g 'daemon off;'
