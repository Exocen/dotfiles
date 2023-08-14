FROM debian:latest
ARG DOMAIN

VOLUME /etc/letsencrypt/
VOLUME /post_base/
VOLUME /var/mail/vhosts/
#TODO var log

ENV DEBIAN_FRONTEND="noninteractive"
RUN apt-get -y update
RUN apt-get -y upgrade
RUN apt-get install -y --no-install-recommends sudo syslog-ng cron postfix dovecot-core dovecot-imapd dovecot-lmtpd opendkim opendkim-tools

WORKDIR /root/
COPY config_files/ docker_entrypoint.sh /root/
RUN /bin/bash -c 'chmod +x /root/*.sh'
RUN /root/confs_install.sh $DOMAIN

ENTRYPOINT ["/root/docker_entrypoint.sh"]
