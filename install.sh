#!/bin/bash
RED="31"
GREEN="32"
WOS=""

function makeItColorful {
    echo -e "\e[$2m$1\e[0m"
}

function is_working {
    if [ $? -eq 0 ];then
        makeItColorful "Success : $1" $GREEN
    else
        makeItColorful "Fail : $1" $RED
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
        WOS="WTH?"
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
    is_working "pulling oh-my-zsh config"
}

function home_ln {
    ln -sf `pwd`/$1 -t ~/ > /dev/null 2>&1
    is_working "ln $1 on ~"
}

function home_cp {
    unalias cp > /dev/null 2>&1
    cp -fr `pwd`/$1 ~/$1 > /dev/null 2>&1
    is_working "Copy $1 to ~"
    alias cp="cp -iv" > /dev/null 2>&1
}

# Faire un detectOS avant
function ins {
    all="$@" # pour fonction is_working
    echo "Installation: $all ...."
    if [ "$WOS" = "Ubuntu" ] || [ "$WOS" = "Debian" ] ;then
        sudo apt update -y > /dev/null 2>&1
        sudo apt install $@ -y # > /dev/null 2>&1
        is_working "$all installed"
    elif [ "$WOS" = "Fedora" ] ;then
        sudo dnf update -y #> /dev/null 2>&1
        sudo dnf install $@ -y #> /dev/null 2>&1
        is_working "$all installed"
    elif [ "$WOS" = "Arch" ] ;then
        yaourt-install
        yaourt -Sau --noconfirm
        yaourt -Sy $@ --noconfirm #> /dev/null 2>&1
        is_working "$all installed"
    else
        makeItColorful "Unknow OS" $RED
    fi
}

function yaourt-install {
    grep -v "archlinux" /etc/pacman.conf | grep -v "SigLevel = Never" > /tmp/pacman.conf
    echo '[archlinuxfr]
SigLevel = Never
Server = http://repo.archlinux.fr/$arch' >> /tmp/pacman.conf
    sudo mv /tmp/pacman.conf /etc/pacman.conf
    sudo pacman -Sy yaourt --noconfirm
    is_working "Yaourt installation"
}

function make {
    detectOS
    cloneOhmyZsh
    home_ln .zshrc
    home_ln .xinitrc
    home_ln .emacs
    home_cp .oh-my-zsh/
    home_cp .oh-my-zsh/.*
    ins vim git htop iftop iotop tree zsh make wget sudo
    chsh -s /usr/bin/zsh
    if  [ "$1" = "f" ]
    then
        {
            home_ln .i3
            home_ln .zprofile #if no GDM
            ins clementine tig nethogs nitrogen numlockx mcomix thunar ttf-font-awesome blueman pulseaudio-bluetooth #bluetooth
        }
    else
        {
            echo "'f' Argument full installation"
        }
    fi

}
make $1
exit 0

# Local Variables:
# mode: Shell-script
# coding: mule-utf-8
# End:
