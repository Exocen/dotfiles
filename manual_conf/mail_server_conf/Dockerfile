FROM debian:latest
ARG DOMAIN

VOLUME /etc/letsencrypt/
VOLUME /post_base/
VOLUME /var/mail/vhosts/
EXPOSE 25/TCP 587/TCP 465/TCP 143/TCP 993/TCP 80/TCP

ENV DEBIAN_FRONTEND="noninteractive"
RUN apt-get -y update
RUN apt-get -y upgrade
RUN apt-get install -y --no-install-recommends sudo cron postfix dovecot-core dovecot-imapd dovecot-lmtpd opendkim opendkim-tools certbot

WORKDIR /tmp/tmp_conf
COPY . /tmp/tmp_conf

RUN find . -type f -print0 | xargs -0 sed -i 's/\[DOMAIN\]/'$DOMAIN'/g'

RUN cp -fr postfix/* /etc/postfix/ && chmod -R o-rwx /etc/postfix
RUN touch /post_base/vmailbox && postmap /post_base/vmailbox
RUN touch /post_base/virtual_alias && postmap /post_base/virtual_alias
RUN newaliases

RUN cp -fr dovecot.conf /etc/dovecot/ && mkdir -p /var/mail/vhosts/$DOMAIN && groupadd -g 5000 vmail && useradd -g vmail -u 5000 vmail -d /var/mail && chown -R vmail:vmail /var/mail && chown -R vmail:dovecot /etc/dovecot && chmod -R o-rwx /etc/dovecot

RUN cp -fr opendkim.conf /etc/ && mkdir -p /etc/opendkim/keys/$DOMAIN && cp -fr opendkim/* /etc/opendkim/ && opendkim-genkey -s mail -d $DOMAIN -D /etc/opendkim/keys/$DOMAIN && chown opendkim:opendkim /etc/opendkim/keys/$DOMAIN/mail.private && chmod 0400 /etc/opendkim/keys/$DOMAIN/mail.private && cp -fr /etc/opendkim/keys/$DOMAIN/*.txt /post_base/

RUN chmod +x docker_entrypoint.sh
RUN cp -fr docker_entrypoint.sh /root
WORKDIR /root/
RUN rm -rf /tmp/tmp_conf
ENTRYPOINT ["/root/docker_entrypoint.sh"]
