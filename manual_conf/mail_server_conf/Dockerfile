FROM debian:latest
ARG DOMAIN

VOLUME /etc/letsencrypt/
VOLUME /post_base/
VOLUME /var/mail/vhosts/
#TODO var log
EXPOSE 25/TCP 587/TCP 465/TCP 143/TCP 993/TCP 80/TCP

ENV DEBIAN_FRONTEND="noninteractive"
RUN apt-get -y update
RUN apt-get -y upgrade
RUN apt-get install -y --no-install-recommends sudo syslog-ng cron postfix dovecot-core dovecot-imapd dovecot-lmtpd opendkim opendkim-tools certbot procps

WORKDIR /tmp/tmp_conf
COPY confs* docker_entrypoint.sh /tmp/tmp_conf/

RUN ./confs_install.sh $DOMAIN

WORKDIR /root/
RUN chmod +x /tmp/tmp_conf/docker_entrypoint.sh && cp -fr /tmp/tmp_conf/docker_entrypoint.sh /root && rm -rf /tmp/tmp_conf
ENTRYPOINT ["/root/docker_entrypoint.sh"]
