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
VOLUME /post_base/
VOLUME /var/mail/vhosts/
EXPOSE 25/TCP 587/TCP 465/TCP 143/TCP 993/TCP

WORKDIR /home/nuser/dotfiles/manual_conf/mail_server_conf/
ENTRYPOINT sudo ./install.sh $DOMAIN
