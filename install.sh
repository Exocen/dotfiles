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
        sudo dnf install -y --nogpgcheck http://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-stable.noarch.rpm
        sudo dnf install -y --nogpgcheck http://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-stable.noarch.rpm
    elif [ -f /etc/centos-release ]; then
        WOS="CentOS"
    elif [ -f /etc/debian_version ]; then
        WOS="Debian"
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
        sudo aptitude update -y > /dev/null 2>&1
        sudo aptitude install $@ -y # > /dev/null 2>&1
        is_working "Installation de $all"
    elif [ "$WOS" = "Fedora" ] ;then
        sudo dnf update -y #> /dev/null 2>&1
        sudo dnf install $@ -y #> /dev/null 2>&1
        is_working "Installation de $all"
    else
        makeItColorful "OS Inconnu" $RED
    fi
}


function make {
    detectOS
    home_ln .emacs
    cloneOhmyZsh
    home_ln .zshrc
    home_cp .oh-my-zsh/
    home_cp .oh-my-zsh/.*
    ins emacs vlc git htop mosh tree zsh make
    chsh -s /usr/bin/zsh
    if [ "$1" = "c" ]
    then
    {
    wget https://dl-ssl.google.com/linux/linux_signing_key.pub

    rpm --import linux_signing_key.pub

    sh -c 'echo "[google-chrome]
    name=Google Chrome 32-bit
    baseurl=http://dl.google.com/linux/chrome/rpm/stable/i386" >> /etc/yum.repos.d/google-chrome.repo'
    }
    else
        {
            echo "Argument 'c' pour installation chrome"
        }
    fi
    if  [ "$1" = "f" ]
    then
        {
            home_ln .i3
            ins comix clementine java-1.8.0-openjdk-devel ruby-devel i3 nitrogen numlockx i3lock i3status xbacklight fontawesome-fonts-web sysstat network-manager-applet acpi
        }
    else
        {
            echo "Argument 'f' pour installation complète"
        }
    fi
    if [ "$1" = "l" ]
    then {
        ins texlive texlive-latex
    }
    else
        {
            echo "Argument 'l' pour installation latex"
        }
    fi

}
make $1
exit 0

# Local Variables:
# mode: Shell-script
# coding: mule-utf-8
# End:
