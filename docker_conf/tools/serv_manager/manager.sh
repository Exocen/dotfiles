#!/bin/bash
# Should be runned by systemd with network dependency and fail to mail

LOCKFILE="/var/run/$(basename "$0").lock"
INTERVAL="15 minutes"
CHECK_INTERVAL=$((`date -d "$INTERVAL" +%s` - `date +%s`))
MAX_FAIL_SCORE=2

MAIL_SERVER_FAIL_SCORE=0
NGINX_CERTBOT_FAIL_SCORE=0
VAULTWARDEN_FAIL_SCORE=0
GITEA_FAIL_SCORE=0

MAIL_SERV_BOOTED=false

safe_exit() {
    echo "$1"
    rm -f "$LOCKFILE"
    exit "$2"
}

inspect() {
    docker inspect -f '{{.State.Status}}' $1 | grep -P "^running$" 1>/dev/null && docker inspect -f '{{.State.Health.Status}}' $1 | grep -P "(^healthy$)|(^starting$)"
}

sendmail() {
    # MAIL_SERV need to get a positive check (at least once)
    if [ $MAIL_SERVER_FAIL_SCORE -eq 0 ] && [ $MAIL_SERV_BOOTED = true ] ; then
        #TODO get $1 logs
        # use mail_server smtp
        echo "mail"
    else
        echo "main mail"
    fi
}

# $1 cont name / $2 score
refresh_score() {
    if inspect $1; then
        [ $MAIL_SERV_BOOTED = false ] && [ $1 = "mail_server" ] && MAIL_SERV_BOOTED=true
        echo 0
    elif [ $2 -lt $MAX_FAIL_SCORE ] ; then
        sendmail $1
        docker restart $1
        echo $(( $2 + 1 ))
    else
        echo $2
    fi
}

kill_handler() {
    safe_exit "KILL catched, exiting." 0
}

terminator() {
    kill -9 $1 1>/dev/null
    [ -f "$LOCKFILE" ] && ps -p $(cat "$LOCKFILE") > /dev/null && echo "Can't kill $1, exiting." && exit 1
}

check_lock()  {
    [ -f "$LOCKFILE" ] && ps -p $(cat "$LOCKFILE") > /dev/null && echo "$(basename "$0") is already running, restarting..." && terminator $(cat "$LOCKFILE")
    echo $$ > "$LOCKFILE"
}

checker() {
    while true;
    do
        MAIL_SERVER_FAIL_SCORE=`refresh_score "mail_server" $MAIL_SERVER_FAIL_SCORE`
        NGINX_CERTBOT_FAIL_SCORE=`refresh_score "nginx_certbot" $NGINX_CERTBOT_FAIL_SCORE`
        VAULTWARDEN_FAIL_SCORE=`refresh_score "vaultwarden" $VAULTWARDEN_FAIL_SCORE`
        sleep $CHECK_INTERVAL
    done
}

start() {
    docker start mail_server
    docker start nginx_certbot
    docker start vaultwarden

    # Healthcheck need 30s to start
    sleep 1m
    checker
}

stop() {
    docker stop mail_server
    docker stop nginx_certbot
    docker stop vaultwarden
}

reload() {
    stop
    start
}

main() {
    [ `id -u` -ne 0 ] && safe_exit "Must be run as root" 1
    check_lock
    trap term_handler SIGTERM
    case $1 in
        start)  start;;
        reload) reload;;
        stop) stop;;
        * ) echo "USAGE: script start|stop|reload";;
    esac
    safe_exit "$(basename "$0") exiting." 0
}

main $1
