#!/bin/bash

service syslog-ng restart

echo "@daily /usr/bin/certbot renew --nginx"
service cron restart
nginx -g 'daemon off;'
