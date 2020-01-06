#!/usr/bin/env bash

WOS=''
LOCAL=`dirname "$(readlink -f "$0")"`

function is_working {
    if [ $? -eq 0 ];then
        success "$1"
    else
        error "$1"
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
    ln -sfn `pwd`/$1 $2 &>$logFile
    is_working "ln $1 on $2"
}

function home_folder {
    info "Symbolic links to home..."
    for f in $1/*; do
        DEST=$(basename $f)
        ln -sfn `pwd`/$f ~/.$DEST &>$logFile
        is_working "ln $f to ~/.$DEST"
    done
}

function conf_folder {
    info "Symbolic links to .config"
    mkdir -p ~/.config
    for f in $1/*; do
        DEST=$(basename $f)
        ln -sfn `pwd`/$f ~/.config/.$DEST &>$logFile
        is_working "ln $f to ~/.config/.$DEST"
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
    info "Installation: $all "
    if [ "$WOS" = "Ubuntu" ] || [ "$WOS" = "Debian" ] ;then
        sudo apt update -y &>$logFile
        sudo apt install $@ -y &>$logFile
        is_working "$all installed"
    elif [ "$WOS" = "Fedora" ] ;then
        # TODO check rpm first
        sudo dnf install -y --nogpgcheck https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
        sudo dnf install -y --nogpgcheck https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
        sudo dnf update -y &>$logFile
        sudo dnf install $@ -y &>$logFile
        is_working "$all installed"
    elif [ "$WOS" = "Arch" ] ;then
        # Aur tool install
        pacaur -v &>/dev/null
        if [ $? -ne 0 ];then
            arch_package_install https://aur.archlinux.org/auracle-git.git
            arch_package_install https://aur.archlinux.org/pacaur.git
        fi
        pacaur -Syyuu $@ --noedit --needed --noconfirm &>$logFile
        is_working "$all installed"
    else
        error "Unknow OS"
    fi
}

function arch_package_install {
    info "Arch install: $1"
    sudo pacman -S --needed base-devel git --noconfirm &>$logFile
    tmpD=`mktemp -d`
    git clone $1 $tmpD &>$logFile
    cd $tmpD
    makepkg -fsri --skipinteg --noconfirm  &>$logFile
    cd $LOCAL
}

function git_clone {
    info "Cloning $1"
    if $force ; then
        rm -rf $2
        is_working "Removed: $2"
    fi
    if [ -f "$2" ] ; then
        git clone --depth=1 $1 $2
        is_working "Cloned: $1 to $2"
    fi
}

function basic_install {
    info "Basic installation"
    # Basic packages
    ins vim git htop iftop iotop tree zsh make wget sudo
    # ln -s all conf
    home_folder home_conf
    conf_folder conf_conf
    # zsh
    git_clone https://github.com/ohmyzsh/ohmyzsh ~/.oh-my-zsh
    git_clone https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k
    sudo chsh -s /usr/bin/zsh $USER
    # vimrc
    git_clone https://github.com/exocen/vim-conf ~/.vim_runtime
    sh ~/.vim_runtime/install_awesome_vimrc.sh

}

function make {
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
            # reflector
            # reflector --latest 20 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
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


function mainScript() {
    echo -n
    info 'Script started'

    detectOS
    if $force ; then
        echo "force!"
    fi

}

function trapCleanup() {
    echo ""
    # Delete temp files, if any
    if [ -d "${tmpDir}"  ] ; then
        rm -r "${tmpDir}"
    fi
    die "Exit trapped. In function: '${FUNCNAME[*]}'"

}

function safeExit() {
    # Delete temp files, if any
    if [ -d "${tmpDir}"  ] ; then
        rm -r "${tmpDir}"
    fi
    trap - INT TERM EXIT
    if $printLog ; then notice "Log file: $logFile"; fi
    exit

}

# Set Base Variables
# ----------------------
scriptName=$(basename "$0")

# Set Flags
quiet=false
printLog=true
verbose=false
force=false
strict=false
debug=false
args=()

# Set Colors
bold=$(tput bold)
reset=$(tput sgr0)
purple=$(tput setaf 171)
red=$(tput setaf 1)
green=$(tput setaf 76)
tan=$(tput setaf 3)
blue=$(tput setaf 38)
underline=$(tput sgr 0 1)

# Set Temp Directory
tmpDir="/tmp/${scriptName}.$RANDOM.$RANDOM.$RANDOM.$$"
(umask 077 && mkdir "${tmpDir}") || {
    die "Could not create temporary directory! Exiting."

}

# Logging
# -----------------------------------
# Log is only used when the '-l' flag is set.
logFile="/tmp/${scriptName}.log"


# Options and Usage
# -----------------------------------
usage() {
    echo -n "${scriptName} [OPTION]... [FILE]...

    This is a script template.  Edit this description to print help to users.

    ${bold}Options:${reset}
    --force           Skip all user interaction.  Implied 'Yes' to all actions.
    -q, --quiet       Quiet (no output)
    -l, --log         Print log to file
    -v, --verbose     Output more information. (Items echoed to 'verbose')
    -d, --debug       Runs script in BASH debug mode (set -x)
    -h, --help        Display this help and exit
    --version     Output version information and exit
    "

}

# Iterate over options breaking -ab into -a -b when needed and --foo=bar into
# --foo bar
optstring=h
unset options
while (($#)); do
    case $1 in
        # If option is of type -ab
        -[!-]?*)
        # Loop over each character starting with the second
        for ((i=1; i < ${#1}; i++)); do
            c=${1:i:1}

            # Add current char to options
            options+=("-$c")

            # If option takes a required argument, and it's not the last char make
            # the rest of the string its argument
            if [[ $optstring = *"$c:"* && ${1:i+1}  ]]; then
                options+=("${1:i+1}")
                break
            fi
        done
        ;;

        # If option is of type --foo=bar
        --?*=*) options+=("${1%%=*}" "${1#*=}") ;;
        # add --endopts for --
        --) options+=(--endopts) ;;
        # Otherwise, nothing special
        *) options+=("$1") ;;
    esac
    shift
done
set -- "${options[@]}"
unset options

# Print help if no arguments were passed.
# Uncomment to force arguments when invoking the script
# -------------------------------------
[[ $# -eq 0  ]] && set -- "--help"

# Read the options and set stuff
while [[ $1 = -?* ]]; do
    case $1 in
        -h|--help) usage >&2; safeExit ;;
        --version) echo "$(basename $0) ${version}"; safeExit ;;
        -v|--verbose) verbose=true ;;
        -l|--log) printLog=true;;
        -q|--quiet) quiet=true ;;
        -s|--strict) strict=true;;
        -d|--debug) debug=true;;
        --force) force=true ;;
        --endopts) shift; break ;;
        *) die "invalid option: '$1'." ;;
    esac
    shift
done

# Store the remaining part as arguments.
args+=("$@")


# Logging & Feedback
# -----------------------------------------------------
function _alert() {
    if [ "${1}" = "error"  ]; then local color="${bold}${red}"; fi
    if [ "${1}" = "warning"  ]; then local color="${red}"; fi
    if [ "${1}" = "success"  ]; then local color="${green}"; fi
    if [ "${1}" = "debug"  ]; then local color="${purple}"; fi
    if [ "${1}" = "header"  ]; then local color="${bold}${tan}"; fi
    if [ "${1}" = "input"  ]; then local color="${bold}"; fi
    if [ "${1}" = "notice"  ]; then local color="${blue}"; fi
    if [ "${1}" = "info"  ] || [ "${1}" = "notice"  ]; then local color="${blue}"; fi
    # Don't use colors on pipes or non-recognized terminals
    if [[ "${TERM}" != "xterm"*  ]] || [ -t 1  ]; then color=""; reset=""; fi

    # Print to console when script is not 'quiet'
    if ${quiet} || [ "${1}" = "debug"  ]; then true; else
        echo -e "$(date +"%r") ${color}$(printf "[%7s]" "${1}") ${_message}${reset}";
    fi

    # Print to Logfile
    if ${printLog} && [ "${1}" != "input"  ] && [ "${1}" != "notice" ];  then
        color=""; reset="" # Don't use colors in logs
        echo -e "$(date +"%F %T") $(printf "[%7s]" "${1}") ${_message}" >> "${logFile}";
        if [ "${1}" = "debug" ]; then
            echo -e "$(date +"%F %T") $(printf "[%7s]" "run") `${_message} 2>&1`" >> "${logFile}" ;
        fi
    fi
}

function die ()       { local _message="${*} Exiting."; echo -e "$(_alert error)"; safeExit; }
function error ()     { local _message="${*}"; echo -e "$(_alert error)";  }
function warning ()   { local _message="${*}"; echo -e "$(_alert warning)";  }
function notice ()    { local _message="${*}"; echo -e "$(_alert notice)";  }
function info ()      { local _message="${*}"; echo -e "$(_alert info)";  }
function debug ()     { local _message="${*}"; echo -n "$(_alert debug)";  }
function success ()   { local _message="${*}"; echo -e "$(_alert success)";  }
function input()      { local _message="${*}"; echo -n "$(_alert input)";  }
function header()     { local _message="== ${*} ==  "; echo -e "$(_alert header)";  }
function verbose()    { if ${verbose}; then debug "$@"; fi  }

# SEEKING CONFIRMATION
# ------------------------------------------------------
function seek_confirmation() {
    # echo ""
    input "$@"
    if "${force}"; then
        notice "Forcing confirmation with '--force' flag set"
    else
        read -p " (y/n) " -n 1
        echo ""
    fi

}
function is_confirmed() {
    if "${force}"; then
        return 0
    else
        if [[ "${REPLY}" =~ ^[Yy]$  ]]; then
            return 0
        fi
        return 1
    fi

}
function is_not_confirmed() {
    if "${force}"; then
        return 1
    else
        if [[ "${REPLY}" =~ ^[Nn]$  ]]; then
            return 0
        fi
        return 1
    fi

}


# Trap bad exits with your cleanup function
# trap trapCleanup EXIT INT TERM

# Set IFS to preferred implementation
IFS=$' \n\t'

# Exit on error. Append '||true' when you run the script if you expect an error.
# set -o errexit ||true

# Run in debug mode, if set
if ${debug}; then set -x ; fi

# Exit on empty variable
if ${strict}; then set -o nounset ; fi

# Bash will remember & return the highest exitcode in a chain of pipes.
# This way you can catch the error in case mysqldump fails in `mysqldump |gzip`, for example.
set -o pipefail

# Run your script
mainScript

# Exit cleanly
safeExit

