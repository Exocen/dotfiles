#!/bin/bash
CERTBOT_RENEW_DATE='86400' # one day

while true; do
    echo "Certbot renew in $CERTBOT_RENEW_DATE seconds"
    sleep $CERTBOT_RENEW_DATE
    echo "Starting certbot renewal"
    /usr/bin/certbot renew --nginx
    /usr/bin/certbot certificates | grep -P "\(VALID\:" || exit 1
done

