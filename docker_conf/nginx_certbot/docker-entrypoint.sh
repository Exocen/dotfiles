#!/bin/bash
CERTBOT_RENEW_DATE='86400' # one day
LOG_DIR=/etc/letsencrypt/logs/

certbot_renew(){
    while true; do
        /usr/bin/certbot renew --nginx --logs-dir $LOG_DIR
        sleep $CERTBOT_RENEW_DATE
    done
}

mkdir -p /var/log/nginx
mkdir -p /var/log/letsencrypt
mkdir -p $LOG_DIR

/usr/bin/certbot certificates | grep '[DOMAIN]\|*.[DOMAIN]' &>/dev/null
RESULT=$?
if [ $RESULT -ne 0 ]; then
    /usr/bin/certbot --nginx --keep-until-expiring --expand --register-unsafely-without-email --agree-tos --logs-dir $LOG_DIR -q -d [DOMAIN] -d git.[DOMAIN] -d mail.[DOMAIN] -d status.[DOMAIN] -d www.[DOMAIN] -d vw.[DOMAIN]
    /usr/bin/certbot certificates | grep '[DOMAIN]\|*.[DOMAIN]' &>/dev/null
    if [ $? -ne 0 ]; then
        echo "certbot failed exiting..."
        exit 1
    fi
fi

cp -fr /root/nginx.conf /etc/nginx/
certbot_renew &
pkill 'nginx'
nginx -g 'daemon off;'
