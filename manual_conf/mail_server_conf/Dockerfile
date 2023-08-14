FROM debian:latest
ARG DOMAIN

VOLUME /etc/letsencrypt/
VOLUME /post_base/
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
CMD /bin/bash -c 'chmod +x /root/*.sh'
CMD /root/confs_install.sh $DOMAIN

ENTRYPOINT ["/root/docker_entrypoint.sh"]
