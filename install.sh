#!/bin/bash
RED="31"
GREEN="32"
WOS=""

function makeItColorful {
  echo -e "\e[$2m$1\e[0m"
}

function is_working {
  if [ $? -eq 0 ];then
    makeItColorful "Réussite : $1" $GREEN
  else
    makeItColorful "Echec : $1" $RED
  fi
}

function detectOS {
  if [ -f /etc/lsb-release ]; then
    OS=$(cat /etc/lsb-release | grep DISTRIB_ID | sed 's/^.*=//')
    VERSION=$(cat /etc/lsb-release | grep DISTRIB_RELEASE | sed 's/^.*=//')
    if [ "$OS" = "Ubuntu" ] || [ "$OS" = "Debian" ] ;then
      WOS="$OS"
    fi
  elif [ -f /etc/redhat-release ]; then
    WOS="Fedora"
    sudo dnf install -y --nogpgcheck https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
    sudo dnf install -y --nogpgcheck https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
  elif [ -f /etc/centos-release ]; then
    WOS="CentOS"
  elif [ -f /etc/debian_version ]; then
    WOS="Debian"
  elif [ -f /etc/arch-release ]; then
    WOS="Arch"
  else
    WOS="WTF ?"
  fi
}

function cloneOhmyZsh {
  if [ -d ".oh-my-zsh" ]; then
    cd .oh-my-zsh
    git pull https://github.com/exocen/oh-my-zsh master
    cd ..
  else
    git clone https://github.com/exocen/oh-my-zsh .oh-my-zsh/
  fi
  is_working "Clonage de oh-my-zsh"
}

function home_ln {
  ln -sf `pwd`/$1 -t ~/ > /dev/null 2>&1
  is_working "Création de $1 sur ~"
}

function home_cp {
  unalias cp > /dev/null 2>&1
  cp -fr `pwd`/$1 ~/$1 > /dev/null 2>&1
  is_working "Copie de $1 sur ~"
  alias cp="cp -iv" > /dev/null 2>&1
}

# Faire un detectOS avant
function ins {
  all="$@" # pour fonction is_working
  echo "Installation: $all ...."
  if [ "$WOS" = "Ubuntu" ] || [ "$WOS" = "Debian" ] ;then
    sudo apt update -y > /dev/null 2>&1
    sudo apt install $@ -y # > /dev/null 2>&1
    is_working "Installation de $all"
  elif [ "$WOS" = "Fedora" ] ;then
    sudo dnf update -y #> /dev/null 2>&1
    sudo dnf install $@ -y #> /dev/null 2>&1
    is_working "Installation de $all"
  elif [ "$WOS" = "Arch" ] ;then
    yaourt -Sau
    yaourt -Sy $@ --noconfirm #> /dev/null 2>&1
    is_working "Installation de $all"
  else
    makeItColorful "OS Inconnu" $RED
  fi
}


function make {
  detectOS
  cloneOhmyZsh
  home_ln .zshrc
  home_ln .xinitrc
  home_ln .emacs
  home_ln .zprofile #if no GDM
  home_cp .oh-my-zsh/
  home_cp .oh-my-zsh/.*
  ins vim vlc git htop iftop iotop tree zsh make wget #util-linux-user #for fed only
  chsh -s /usr/bin/zsh
  if  [ "$1" = "f" ]
  then
    {
      home_ln .i3
      ins clementine tig nethogs nitrogen numlockx mcomix thunar ttf-font-awesome blueman pulseaudio-bluetooth #bluetooth 
    }
  else
    {
      echo "Argument 'f' pour installation complète"
    }
  fi

}
make $1
exit 0

# Local Variables:
# mode: Shell-script
# coding: mule-utf-8
# End:
