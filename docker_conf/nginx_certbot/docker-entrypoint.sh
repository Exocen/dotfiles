#!/bin/bash
CERTBOT_RENEW_DATE='03:14 tomorrow'

certbot_renew(){
    echo "Starting Certbot renew..."
    /usr/bin/certbot renew --nginx
    echo "Will restart at $CERTBOT_RENEW_DATE"
    sleep $(( $(date -d "$CERTBOT_RENEW_DATE" +%s) - $(date +%s) ))
}

function prefix_cmd {
    local PREF="${1//\//\\/}" # replace / with \/
    shift
    local CMD=("$@")
    ${CMD[@]} 1> >(sed "s/^/${PREF}/") 2> >(sed "s/^/${PREF}/" 1>&2)
}

mkdir -p /var/log/nginx
mkdir -p /var/log/letsencrypt
ln -s /dev/null /var/log/letsencrypt/letsencrypt.log

/usr/bin/certbot certificates | grep 'vw.[DOMAIN]\|www.[DOMAIN]'
RESULT=$?
if [ $RESULT -eq 1 ]; then
   prefix_cmd "Certbot: " /usr/bin/certbot --nginx --keep-until-expiring --expand --register-unsafely-without-email --agree-tos -d [DOMAIN] -d vw.[DOMAIN] -d www.[DOMAIN] | sed -e 's/^/Certbot: /;' || (echo "certbot failed exiting..." && exit 1)
fi

cp -fr /root/nginx.conf /etc/nginx/
prefix_cmd "Certbot: " certbot_renew
prefix_cmd "Nginx: " nginx -g 'daemon off;'
