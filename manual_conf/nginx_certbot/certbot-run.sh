#!/bin/bash

sudo certbot --nginx -d [DOMAIN]

# 0 12 * * * /usr/bin/certbot renew --quiet
# cron -f
nginx -g 'daemon off;'
