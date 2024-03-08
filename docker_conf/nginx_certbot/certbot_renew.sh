#!/bin/bash
CERTBOT_RENEW_DATE='86400' # one day
LOG_DIR=/etc/letsencrypt/logs/

while true; do
    echo "Certbot renew in $CERTBOT_RENEW_DATE s"
    sleep $CERTBOT_RENEW_DATE
    echo "Starting certbot renewal"
    /usr/bin/certbot renew --nginx --logs-dir $LOG_DIR
    /usr/bin/certbot certificates | grep -P "\(VALID\:" || exit 1
done

