#!/bin/bash

# Should be runned bv systemd with auto-start.sh + network dependency and fail to mail
CHECK_INTERVAL="15 minutes"
MAX_FAIL_SCORE=2
do each cont
CONT_FAIL_SCORE=0
MAIL_SERV_BOOTED=false

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
        else
            CONT_FAIL_SCORE=0
            if  not MAIL_SERV_BOOTED and cont is MAIL_SERV -> MAIL_SERV_BOOTED=true
sleep interval

help_container() {
    sendmail $1 logs
    $1_FAIL_SCORE+1
    restart $1
}

sendmail() {
    # MAIL_SERV need to get a positive check (at least once)
    if [ $MAIL_SERV_FAIL_SCORE -eq 0 ] && $MAIL_SERV_BOOTED; then
        use mail_server smtp
    else
        use main smtp
    fi
}
