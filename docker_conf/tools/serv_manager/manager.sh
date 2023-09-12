#!/bin/bash

# Should be runned bv systemd with auto-start.sh + network dependency and fail to mail
CHECK_INTERVAL="15 minutes"
MAX_FAIL_SCORE=2
do each cont
CONT_FAIL_SCORE=0

mail_server
nginx_certbot
vaultwarden
gitea

infini loop
for each
    if (( CONT_FAIL_SCORE >= MAX_FAIL_SCORE ))
        docker inspect -f '{{.State.Status}}' cont | grep "" && \
        docker inspect -f '{{.State.Health.Status}}' cont | grep ""
        if error -> help_container cont
sleep interval

help_container() {
    sendmail $1 logs
    restart $1
    wait $1 health status
    if $1 status still bad -> sendmail $1 log &&  $1_FAIL_SCORE+1
}

sendmail() {
    if [ $MAIL_SERV_FAIL_SCORE -eq 0 ]; then
        use mail_server smtp
    else
        use main smtp
    fi
}
