#!/bin/bash

service syslog-ng restart
echo "@daily /usr/bin/certbot renew --nginx &>/var/log/certbot.log"
service cron restart

nginx -g 'daemon off;'
