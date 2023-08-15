#!/bin/bash

service syslog-ng restart

(echo "@daily /usr/bin/certbot renew --nginx &>/var/log/certbot.log") | crontab -
service cron restart

mkdir -p /var/log/nginx
nginx -g 'daemon off;'
