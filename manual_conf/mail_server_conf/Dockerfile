FROM debian:latest
ARG DOMAIN

VOLUME /etc/letsencrypt/

Compressing objects: 100% (5/5), done.VOLUME /post_base/
VOLUME /var/mail/vhosts/
#TODO var log
EXPOSE 25/TCP 587/TCP 465/TCP 143/TCP 993/TCP 80/TCP

ENV DEBIAN_FRONTEND="noninteractive"
USER root
RUN apt-get -y update
RUN apt-get -y upgrade
RUN apt-get install -y --no-install-recommends sudo syslog-ng cron postfix dovecot-core dovecot-imapd dovecot-lmtpd opendkim opendkim-tools certbot

WORKDIR /root/
COPY confs* docker_entrypoint.sh /root/
RUN /bin/bash -c 'chmod +x /root/*.sh'
RUN /root/confs_install.sh $DOMAIN

ENTRYPOINT ["/root/docker_entrypoint.sh"]
