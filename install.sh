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
        if [ "$OS" = "Ubuntu" ] || [ "$OS" = "Debian" ] || [ "$OS" = "Arch" ];then
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
        # Aur tool install
        pacaur -v $2 > /dev/null 2>&1
        if [ $? -ne 0 ];then
            arch_package_install https://aur.archlinux.org/auracle-git.git
            arch_package_install https://aur.archlinux.org/pacaur.git
        fi
    else
        WOS="WTH?"
    fi
}

function home_ln {
    ln -sfn `pwd`/$1 $2 > /dev/null 2>&1
    is_working "ln $1 on $2"
}

function home_folder {
    for f in $1/*; do
        DEST=$(basename $f)
        ln -sfn `pwd`/$f ~/.$DEST > /dev/null 2>&1
        is_working "ln $f to ~/.$DEST"
    done
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
        pacaur -Syyuu $@ --noedit --needed --noconfirm #> /dev/null 2>&1
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
    home_folder home_conf
    git clone https://github.com/ohmyzsh/ohmyzsh ~/.oh-my-zsh
    git clone https://github.com/bhilburn/powerlevel9k.git ~/.oh-my-zsh/custom/themes/powerlevel9k
    git submodule update --init vim-conf
    home_ln vim-conf ~/.vim_runtime
    ins vim git htop iftop iotop tree zsh make wget sudo
    sh ~/.vim_runtime/install_awesome_vimrc.sh
    sudo chsh -s /usr/bin/zsh $USER
    if  [ "$1" = "-f" ] && [ "$WOS" = "Arch" ]
    then
        {
            git submodule update --init i3-conf
            home_ln i3-conf ~/.i3
            git submodule update --init polybar-conf
            mkdir -p ~/.config
            home_ln polybar-conf ~/.config/polybar
            home_ln termite-conf ~/.config/termite
            # Video Driver ( intel graphics )
            ins xf86-video-intel
            # WM
            ins i3-gaps dmenu xorg-server xorg-xbacklight xorg-xinit xorg-xrandr gsfonts alsa-utils jsoncpp
            # Utils
            ins tig nethogs nitrogen numlockx mcomix thunar termite ttf-fira-code zsh-theme-powerlevel9k firefox vlc
            # Bluetooth
            ins blueman pulseaudio-bluetooth bluez-utils pulseaudio-alsa
            # Music player
            # ins clementine gst-plugins-good gst-plugins-base gst-plugins-bad gst-plugins-ugly qt5-tools
            ins mpd mpc ncmpc #config: cp /usr/share/doc/mpdconf.example .config/mpd/mpd.conf
            # Polybar
            ins polybar-git siji-git ttf-nerd-fonts-symbols
        }
    elif  [ "$1" = "-s" ] && [ "$WOS" = "Arch" ];then
        # Steam uncomment the [multilib] section in /etc/pacman.conf
        ins steam lib32-libpulse lib32-alsa-plugins
    else
        {
            echo "'-f' Argument full installation (Arch Linux only)"
            echo "'-s' Steam installation (Arch Linux only)"
        }
    fi

}
make $1
exit 0

# Local Variables:
# mode: Shell-script
# coding: mule-utf-8
# End:
