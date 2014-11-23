RED="31"
GREEN="32"
WOS=""

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
function makeItColorful {
    echo -e "\e[$2m$1\e[0m"
}

function home_ln {
    ln -s `pwd`/$1 ~/$1 > /dev/null 2>&1
    if [ $? -eq 0 ]
    then
        makeItColorful "Lien $1 sur ~ créé" $GREEN
    else
        makeItColorful "Échec de la création de $1 sur ~" $RED
    fi
}

function home_cp {
    unalias cp > /dev/null 2>&1
    cp -rf `pwd`/$1 ~/$1 > /dev/null 2>&1
    alias cp="cp -iv" > /dev/null 2>&1
    if [ $? -eq 0 ]
    then
        makeItColorful "Copie de $1 sur ~ réussie" $GREEN
    else
        makeItColorful "Échec de la copie de $1 sur ~" $RED
    fi

}

function is_working {

    if [ "$?" = "0" ];then
        makeItColorful "Réussite de : $1" $GREEN
    else
        makeItColorful "Echec de : $1" $RED
    fi

}

# Faire un detectOS avant
function ins {
    if [ "$WOS" = "Ubuntu" ] || [ "$WOS" = "Debian" ] ;then
        sudo aptitude update -y && sudo aptitude install $@ -y
        is_working "Installation"
    elif [ "$WOS" = "Fedora" ] ;then
        sudo yum install $@ -y
        is_working "Installation"
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
