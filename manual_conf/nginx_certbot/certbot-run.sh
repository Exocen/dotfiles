#!/bin/bash

certbot certonly --webroot -w /home/www/letsencrypt -d [DOMAIN]

nginx -g 'daemon off;'
