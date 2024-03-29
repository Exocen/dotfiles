#!/usr/bin/env bash
WOS=''
LOCAL=$(dirname "$(readlink -f "$0")")

sudo () {
    [[ $EUID = 0 ]] || set -- command sudo "$@"
    "$@"
}

function is_working() {
    if [ $? -eq 0 ]; then
        success "$1"
    else
        error "$1"
    fi
}

function detectOS() {
    if [ -f /etc/lsb-release ]; then
        WOS=$(cat /etc/lsb-release | grep -oP 'DISTRIB_ID=\"\K.*(?=\")')
        WOS=${WOS,,} #lower case
    elif [ -f /etc/os-release ]; then
        WOS=$(cat /etc/os-release | grep -oP '^ID=\K.*')
        WOS=${WOS,,} #lower case
    elif [ -f /etc/redhat-release ]; then
        WOS="fedora"
    elif [ -f /etc/centos-release ]; then
        WOS="centOS"
    elif [ -f /etc/debian_version ]; then
        WOS="debian"
    elif [ -f /etc/arch-release ]; then
        WOS="arch"
    else
        WOS="WTH?"
    fi
}

function home_ln() {
    ln -sfn $(pwd)/$1 $2 &>>$logFile
    is_working "ln $1 on $2"
}

function home_folder() {
    info "Symbolic links to home..."
    for f in $LOCAL/$1/*; do
        DEST=$(basename $f)
        ln -sfn $f ~/.$DEST &>>$logFile
        is_working "ln $f to ~/.$DEST"
    done
}

function conf_folder() {
    info "Symbolic links to .config"
    mkdir -p ~/.config
    for f in $LOCAL/$1/*; do
        DEST=$(basename $f)
        ln -sfn $f ~/.config/$DEST &>>$logFile
        is_working "ln $f to ~/.config/$DEST"
    done

}

function home_cp() {
    /bin/cp -fr $(pwd)/$1 ~/$1 >/dev/null 2>&1
    is_working "Copy $1 to ~"
}

# run detectOS before
function ins() {
    all="$@" #for is_working function
    info "Installation: $all "
    if [ "$WOS" = "ubuntu" ] || [ "$WOS" = "debian" ] || [ "$WOS" = "raspbian" ]; then
        sudo apt update -y &>>$logFile
        sudo apt install $@ -y &>>$logFile
        is_working "$all installed"
    elif [ "$WOS" = "fedora" ]; then
        sudo dnf install -y --nogpgcheck https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
        sudo dnf install -y --nogpgcheck https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
        sudo dnf update -y &>>$logFile
        sudo dnf install $@ -y &>>$logFile
        is_working "$all installed"
    elif [ "$WOS" = "arch" ]; then
        sudo pacman -S $@ --needed --noconfirm &>>$logFile
        is_working "$all installed"
    else
        error "Unknow OS: $WOS"
    fi
}

function aur_ins() {
    all="$@" #for is_working function
    info "Installation: $all "
    if [ "$WOS" = "arch" ]; then
        # Aur tool install
        paru -V &>/dev/null
        if [ $? -ne 0 ]; then
            arch_package_install https://aur.archlinux.org/paru.git
        fi
        paru -S $@ --needed --noconfirm &>>$logFile
        is_working "$all installed"
    else
        error "Invalid OS"
    fi

}

function arch_package_install() {
    info "Arch install: $1"
    sudo pacman -S --needed base-devel git --noconfirm &>>$logFile
    tmpD=$(mktemp -d)
    git clone $1 $tmpD &>>$logFile
    current_dir=`pwd`
    cd $tmpD
    makepkg -fsri --skipinteg --noconfirm &>>$logFile
    cd $current_dir
    rm -rf $tmpD
}

function git_clone() {
    info "Cloning $1"
    if [ ! -e "$2" ]; then
        git clone --depth=1 $1 $2 &>>$logFile
        is_working "Cloned: $1 to $2"
    else
        warning "$2 already present"
    fi
}

function basic_install() {
    info "Basic installation"
    # Basic packages
    ins vim git htop iftop iotop tree zsh make wget sudo rsync

    # zsh
    ln -sfn $LOCAL/user_conf/zshrc  ~/.zshrc
    git_clone https://github.com/ohmyzsh/ohmyzsh ~/.oh-my-zsh
    ln -sfn $LOCAL/user_conf/custom.zsh-theme ~/.oh-my-zsh/custom/themes
    sudo chsh -s /usr/bin/zsh $USER

    # vimrc
    git_clone https://github.com/exocen/vim-conf ~/.vim_runtime
    sh ~/.vim_runtime/install_awesome_vimrc.sh &>>$logFile
    cd ~/.vim_runtime
    sh ~/.vim_runtime/update.sh &>>$logFile
    cd $LOCAL
}

function dev_env_install() {
    if [ "$WOS" = "arch" ] && [ $EUID != 0 ]; then
        seek_confirmation 'Install Dev Env ?'
        if is_confirmed; then
            {
                file="$LOCAL/arch-package-list"
                if [ -f "$file" ]; then
                    info "Arch dev inv installation"
                    # .config links
                    ln -sfn $LOCAL/user_conf/zprofile  ~/.zprofile
                    conf_folder user_conf/home_conf
                    list=""
                    while IFS= read -r line; do
                        char=$(echo $line | head -c1)
                        if [ "$char" != "#" ]; then
                            list="$list $line"
                        fi
                    done <"$file"

                    aur_ins $list
                else
                    error "Missing $file"
                fi
            }
        fi
    fi
}

function mainScript() {
    echo -n
    info 'Script started'
    if [ -z "$EDITOR" ]; then
        export EDITOR=nano
    fi
    detectOS
    basic_install
    dev_env_install
}

function trapCleanup() {
    echo ""
    # Delete temp files, if any
    if [ -d "${tmpDir}" ]; then
        rm -r "${tmpDir}"
    fi
    die "Exit trapped. In function: '${FUNCNAME[*]}'"

}

function safeExit() {
    # Delete temp files, if any
    if [ -d "${tmpDir}" ]; then
        rm -r "${tmpDir}"
    fi
    trap - INT TERM EXIT
    if $printLog; then
        echo -e "$(date +"%r") ${blue}$(printf "[%7s]" "info") "Logfile: $logFile"${reset}"
    fi
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
noconfirm=false
args=()

# Set Colors
bold=$(tput bold)
reset=$(tput sgr0)
purple=$(tput setaf 171)
red=$(tput setaf 1)
green=$(tput setaf 76)
yellow=$(tput setaf 3)
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

logFile="/tmp/${scriptName}-`date "+%s"`.log"

# Options and Usage
# -----------------------------------
usage() {
    echo -n "${scriptName} [OPTION]... [FILE]...

    This is a script template.  Edit this description to print help to users.

    ${bold}Options:${reset}
    -f, --force       Force re-install and removes previous installations
    -v, --verbose     Output more information. (Items echoed to 'verbose')
    -d, --debug       Runs script in BASH debug mode (set -x)
    -y, --noconfirm   Skip all user interaction.  Implied 'Yes' to all actions.
    -h, --help        Display this help and exit
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
        for ((i = 1; i < ${#1}; i++)); do
            c=${1:i:1}

            # Add current char to options
            options+=("-$c")

            # If option takes a required argument, and it's not the last char make
            # the rest of the string its argument
            if [[ $optstring = *"$c:"* && ${1:i+1} ]]; then
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
# [[ $# -eq 0  ]] && set -- "--help"

# Read the options and set stuff
while [[ $1 = -?* ]]; do
    case $1 in
        -h | --help)
            usage >&2
            safeExit
            ;;
        -v | --verbose) verbose=true ;;
        -l | --log) printLog=true ;;
        -q | --quiet) quiet=true ;;
        -d | --debug) debug=true ;;
        -f | --force) force=true ;;
        -y | --noconfirm) noconfirm=true ;;
        --endopts)
            shift
            break
            ;;
        *) die "invalid option: '$1'." ;;
    esac
    shift
done

# Store the remaining part as arguments.
args+=("$@")

# Logging & Feedback
# -----------------------------------------------------
function _alert() {
    if [ "${1}" = "error" ]; then local color="${bold}${red}"; fi
    if [ "${1}" = "warning" ]; then local color="${yellow}"; fi
    if [ "${1}" = "success" ]; then local color="${green}"; fi
    if [ "${1}" = "debug" ]; then local color="${purple}"; fi
    if [ "${1}" = "header" ]; then local color="${bold}${tan}"; fi
    if [ "${1}" = "input" ]; then local color="${bold}"; fi
    if [ "${1}" = "notice" ]; then local color="${blue}"; fi
    if [ "${1}" = "info" ] || [ "${1}" = "notice" ]; then local color="${blue}"; fi
    # Don't use colors on pipes or non-recognized terminals
    if [[ "${TERM}" != "xterm"* ]] || [ -t 1 ]; then
        color=""
        reset=""
    fi

    # Print to console when script is not 'quiet'
    if ${quiet} || [ "${1}" = "debug" ]; then true; else
        echo -e "$(date +"%T") ${color}$(printf "[%7s]" "${1}") ${_message}${reset}"
    fi

    # Print to Logfile
    if ${printLog} && [ "${1}" != "input" ] && [ "${1}" != "notice" ]; then
        color=""
        reset="" # Don't use colors in logs
        echo -e "$(date +"%F %T") $(printf "[%7s]" "${1}") ${_message}" >>"${logFile}"
        if [ "${1}" = "debug" ]; then
            echo -e "$(date +"%F %T") $(printf "[%7s]" "run") $(${_message} 2>&1)" >>"${logFile}"
        fi
    fi
}

function die() {
    local _message="${*} Exiting."
    echo -e "$(_alert error)"
    safeExit
}
function error() {
    local _message="${*}"
    echo -e "$(_alert error)"
}
function warning() {
    local _message="${*}"
    echo -e "$(_alert warning)"
}
function notice() {
    local _message="${*}"
    echo -e "$(_alert notice)"
}
function info() {
    local _message="${*}"
    echo -e "$(_alert info)"
}
function debug() {
    local _message="${*}"
    echo -n "$(_alert debug)"
}
function success() {
    local _message="${*}"
    echo -e "$(_alert success)"
}
function input() {
    local _message="${*}"
    echo -n "$(_alert input)"
}
function header() {
    local _message="== ${*} ==  "
    echo -e "$(_alert header)"
}
function verbose() { if ${verbose}; then debug "$@"; fi; }

# SEEKING CONFIRMATION
# ------------------------------------------------------
function seek_confirmation() {
    # echo ""
    input "$@"
    if "${noconfirm}"; then
        notice "Forcing confirmation with '--noconfirm' flag set"
    else
        read -p " (y/N) " -n 1
        echo ""
    fi

}
function is_confirmed() {
    if [[ "${REPLY}" =~ ^[Yy]$ ]] || "${noconfirm}"; then
        return 0
    fi
    return 1

}
function is_not_confirmed() {
    if [[ "${REPLY}" =~ ^[Nn]$ ]]; then
        return 0
    fi
    return 1

}

# Set IFS to preferred implementation
IFS=$' \n\t'

# Run in debug mode, if set
if ${debug}; then set -x; fi

# Exit on empty variable
if ${strict}; then set -o nounset; fi

# Bash will remember & return the highest exitcode in a chain of pipes.
# This way you can catch the error in case mysqldump fails in `mysqldump |gzip`, for example.
set -o pipefail

# Run your script
mainScript

# Exit cleanly
safeExit
