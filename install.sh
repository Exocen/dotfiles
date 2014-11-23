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
    elif [ -f /etc/centos-release ]; then
        WOS="CentOS"
    else
        WOS="WTF ?"
    fi
}

function home_ln {
    ln -s `pwd`/$1 ~/$1 > /dev/null 2>&1
    is_working "Création de $1 sur ~"
}

function home_cp {
    unalias cp > /dev/null 2>&1
    cp -rf `pwd`/$1 ~/$1 > /dev/null 2>&1
    is_working "Copie de $1 sur ~"
    alias cp="cp -iv" > /dev/null 2>&1
}

# Faire un detectOS avant
function ins {
    all="$@" # pour fonction is_working
    if [ "$WOS" = "Ubuntu" ] || [ "$WOS" = "Debian" ] ;then
        sudo aptitude update -y  > /dev/null 2>&1
        sudo aptitude install $@ -y > /dev/null 2>&1
        is_working "Installation de $all"
    elif [ "$WOS" = "Fedora" ] ;then
        sudo yum install $@ -y > /dev/null 2>&1
        is_working "Installation de $all"
    else
        makeItColorful "OS Inconnu" $RED
    fi
}

detectOS
home_ln .emacs
home_ln .zshrc
home_cp .oh-my-zsh/
home_cp .oh-my-zsh/.*
ins emacs vlc git htop mosh

exit 0

# Local Variables:
# mode: Shell-script
# coding: mule-utf-8
# End:
