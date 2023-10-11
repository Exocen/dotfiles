#!/bin/bash
pidof opendkim 1>/dev/null && echo "opendkim is running." || exit 1
service dovecot status && service postfix status || exit 1
