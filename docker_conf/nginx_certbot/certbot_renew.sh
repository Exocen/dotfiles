#!/bin/bash
CERTBOT_RENEW_DATE='86400' # one day

while true; do
    echo "Certbot renew in $CERTBOT_RENEW_DATE seconds"
    sleep $CERTBOT_RENEW_DATE
    echo "Starting certbot renewal"
    /usr/bin/certbot renew --nginx --max-log-backups 0
    /usr/bin/certbot certificates --max-log-backups 0 | grep -P "\(VALID\:" || exit 1
done
