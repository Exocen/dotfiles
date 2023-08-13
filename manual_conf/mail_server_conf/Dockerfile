FROM debian:latest
ARG DOMAIN

VOLUME /etc/letsencrypt/
VOLUME /post_base/
VOLUME /var/mail/vhosts/
#TODO var log
EXPOSE 25/TCP 587/TCP 465/TCP 143/TCP 993/TCP 80/TCP

ENV DEBIAN_FRONTEND="noninteractive"
RUN apt-get -y update \
&& apt-get -y upgrade \
&& apt-get install -y --no-install-recommends sudo syslog-ng cron postfix dovecot-core dovecot-imapd dovecot-lmtpd opendkim opendkim-tools certbot procps

WORKDIR /tmp/tmp_conf
COPY . /tmp/tmp_conf

RUN find . -type f -print0 | xargs -0 sed -i 's/\[DOMAIN\]/'$DOMAIN'/g' \
\
&& mkdir /pre_base && cp -fr postfix/* /etc/postfix/ && chmod -R o-rwx /etc/postfix && touch /pre_base/vmailbox && postmap /pre_base/vmailbox && touch /pre_base/virtual_alias && postmap /pre_base/virtual_alias && newaliases \
\
&& cp -fr dovecot.conf /etc/dovecot/ && mkdir -p /var/mail/vhosts/$DOMAIN && groupadd -g 5000 vmail && useradd -g vmail -u 5000 vmail -d /var/mail && chown -R vmail:vmail /var/mail && chown -R vmail:dovecot /etc/dovecot && chmod -R o-rwx /etc/dovecot \
\
&& cp -fr opendkim.conf /etc/ && mkdir -p /etc/opendkim/keys/$DOMAIN && cp -fr opendkim/* /etc/opendkim/ && opendkim-genkey -s mail -d $DOMAIN -D /pre_base && chown opendkim:opendkim /pre_base/mail.private && chmod 0400 /pre_base/mail.private

WORKDIR /root/
RUN chmod +x /tmp/tmp_conf/docker_entrypoint.sh && cp -fr /tmp/tmp_conf/docker_entrypoint.sh /root && rm -rf /tmp/tmp_conf
ENTRYPOINT ["/root/docker_entrypoint.sh"]
