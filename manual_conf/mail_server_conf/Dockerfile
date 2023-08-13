FROM debian:latest
ARG DOMAIN

VOLUME /etc/letsencrypt/archive/
VOLUME /post_base/
VOLUME /var/mail/vhosts/
EXPOSE 25/TCP 587/TCP 465/TCP 143/TCP 993/TCP 80/TCP

ENV DEBIAN_FRONTEND="noninteractive"
RUN apt-get -y update
RUN apt-get -y upgrade
RUN apt-get install -y --no-install-recommends sudo postfix dovecot-core dovecot-imapd dovecot-lmtpd opendkim opendkim-tools certbot

WORKDIR /tmp/tmp_conf
COPY . /tmp/tmp_conf

RUN find . -type f -print0 | xargs -0 sed -i 's/\[DOMAIN\]/'$DOMAIN'/g'

RUN cp -fr postfix/* /etc/postfix/
RUN chmod -R o-rwx /etc/postfix

RUN touch /post_base/vmailbox && postmap /post_base/vmailbox
RUN touch /post_base/virtual_alias && postmap /post_base/virtual_alias
RUN newaliases

RUN cp -fr dovecot.conf /etc/dovecot/
RUN  mkdir -p /var/mail/vhosts/$DOMAIN
RUN groupadd -g 5000 vmail
RUN useradd -g vmail -u 5000 vmail -d /var/mail
RUN chown -R vmail:vmail /var/mail
RUN chown -R vmail:dovecot /etc/dovecot
RUN chmod -R o-rwx /etc/dovecot

RUN cp -fr opendkim.conf /etc/

RUN mkdir -p /etc/opendkim/keys/$DOMAIN
RUN cp -fr opendkim/* /etc/opendkim/
RUN  opendkim-genkey -s mail -d $DOMAIN -D /etc/opendkim/keys/$DOMAIN
RUN  chown opendkim:opendkim /etc/opendkim/keys/$DOMAIN/mail.private
RUN  chmod 0400 /etc/opendkim/keys/$DOMAIN/mail.private

RUN service postfix restart
RUN service dovecot restart
RUN service opendkim restart
RUN cp -fr /etc/opendkim/keys/$DOMAIN/*.txt /post_base/

ENTRYPOINT certbot certonly -n --keep --standalone --register-unsafely-without-        >  \email --agree-tos -d $DOMAIN
