#!/bin/bash
certbot certificates | grep -P "\(VALID\:" || exit 1
[ -e /var/run/nginx.pid ] || exit 1
