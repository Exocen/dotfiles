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
    docker inspect -f '{{.State.Status}}' $1 | grep -P "^running$" &>/dev/null && docker inspect -f '{{.State.Health.Status}}' $1 | grep -P "(^healthy$)" &>/dev/null
}

sendmail() {
    # MAIL_SERV need to get a positive check (at least once)
    if [ "$MAIL_SERVER_FAIL_SCORE" -eq 0 ] && [ "$MAIL_SERV_BOOTED" = true ] ; then
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

error_handler() {
    echo "$1 failed ($2)."
    sendmail $1
    docker restart $1 1>/dev/null && echo "Restarting $1."
}

main_loop() {
    while true;
    do
        local TMP=`refresh_score "mail_server" $MAIL_SERVER_FAIL_SCORE`
        [ $TMP -gt $MAIL_SERVER_FAIL_SCORE ] && error_handler "mail_server" $TMP
        MAIL_SERVER_FAIL_SCORE=$TMP

        local TMP2=`refresh_score "nginx_certbot" $NGINX_CERTBOT_FAIL_SCORE`
        [ $TMP2 -gt $NGINX_CERTBOT_FAIL_SCORE ] && error_handler "nginx_certbot" $TMP2
        NGINX_CERTBOT_FAIL_SCORE=$TMP2

        local TMP3=`refresh_score "vaultwarden" $VAULTWARDEN_FAIL_SCORE`
        [ $TMP3 -gt $VAULTWARDEN_FAIL_SCORE ] && error_handler "vaultwarden" $TMP3
        VAULTWARDEN_FAIL_SCORE=$TMP3

        sleep $CHECK_INTERVAL
    done
}

docker_start() {
    for cont in "$@"
    do
        docker start $cont 1>/dev/null && echo "$cont started."
    done
}

docker_stop() {
    for cont in "$@"
    do
        docker stop $cont 1>/dev/null && echo "$cont stopped."
    done
}
start() {
    docker_start mail_server nginx_certbot vaultwarden
    # Healthcheck need 30s to start
    sleep 2m
    main_loop
}

stop() {
    docker_stop mail_server nginx_certbot vaultwarden
}

reload() {
    stop
    start
}

main() {
    [ `id -u` -ne 0 ] && echo "Must be run as root" && exit 1
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
