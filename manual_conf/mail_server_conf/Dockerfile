FROM debian:latest

RUN apt-get -y update
RUN apt-get -y upgrade
RUN apt-get install -y git sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
RUN useradd -m -g users -G sudo nuser
USER nuser
WORKDIR /home/nuser
RUN git clone https://github.com/exocen/dotfiles.git
RUN ~/dotfiles/install.sh -y

VOLUME /etc/letsencrypt/archive/$DOMAIN/
WORKDIR /home/nuser/dotfiles/manual_conf/mail_server_conf/
RUN sudo ./install.sh $DOMAIN

VOLUME /post_base/
VOLUME /var/mail/vhosts/

RUN service rsyslog start
RUN service postfix start
RUN service dovecot start
RUN service opendkim start

EXPOSE 25/TCP 587/TCP 465/TCP 143/TCP 993/TCP

RUN tail -f /et
