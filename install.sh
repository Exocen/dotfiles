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

# run detectOS before
function ins {
    all="$@" #for is_working function
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
	# aurman
        arch_package_install https://aur.archlinux.org/aurman.git 
        aurman -Syu $@ --noedit --noconfirm #> /dev/null 2>&1
        is_working "$all installed"
    else
        makeItColorful "Unknow OS" $RED
    fi
}

function arch_package_install {
    sudo pacman -S --needed base-devel git --noconfirm
    git clone $1 install_folder
    cd install_folder
    makepkg -fsri --skipinteg --noconfirm
    cd ..
    rm -rf install_folder
}

function make {
    detectOS
    home_ln .zshrc
    home_ln .xinitrc
    home_ln .emacs
    git submodule update --init .oh-my-zsh
    home_ln .oh-my-zsh
    ins vim git htop iftop iotop tree zsh make wget sudo
    chsh -s /usr/bin/zsh
    if  [ "$1" = "f" ]
    then
        {
            git submodule update --init .i3
            home_ln .i3
            home_ln .zprofile #if no GDM
            ins clementine tig nethogs nitrogen numlockx mcomix thunar ttf-font-icons i3 dmenu xorg-xinit alsa-utils blueman pulseaudio-bluetooth #bluetooth
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
