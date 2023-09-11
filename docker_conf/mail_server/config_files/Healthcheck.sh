#!/bin/bash
#TODO send email and check
#need to precreate test user
# check with msmtp, other, or internal
pidof opendkim || exit 1
service dovecot status && service postfix status || exit 1
