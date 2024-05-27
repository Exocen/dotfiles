#!/usr/bin/env bash
WOS=''
LOCAL=$(dirname "$(readlink -f "$0")")

sudoless() {
    [[ $EUID = 0 ]] || set -- command sudo "$@"
    "$@"
}

function is_working() {
    if [ $? -eq 0 ]; then
        success "$1"
    else
        success_state=false
        error "$1"
    fi
}

function detectOS() {
    if [ -f /etc/lsb-release ]; then
        WOS=$(grep -oP 'DISTRIB_ID=\"\K.*(?=\")' /etc/lsb-release)
        WOS=${WOS,,} #lower case
    elif [ -f /etc/os-release ]; then
        WOS=$(grep -oP '^ID=\K.*' /etc/os-release)
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

function conf_folder() {
    info "Symbolic links to .config"
    mkdir -p ~/.config
    for f in "$LOCAL/$1"/*; do
        DEST=$(basename "$f")
        ln -sfn "$f" ~/.config/"$DEST" &>>"$logFile"
        is_working "ln $f to ~/.config/$DEST"
    done

}

# run detectOS before
function ins() {
    read -ra all <<<"$@"
    info "Installation: $* "
    if [ "$WOS" = "ubuntu" ] || [ "$WOS" = "debian" ] || [ "$WOS" = "raspbian" ]; then
        sudoless apt update -y &>>"$logFile"
        sudoless apt install "${all[@]}" -y &>>"$logFile"
        is_working "$* installed"
    elif [ "$WOS" = "fedora" ]; then
        {
            sudoless dnf install -y --nogpgcheck https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-"$(rpm -E %fedora)".noarch.rpm
            sudoless dnf install -y --nogpgcheck https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-"$(rpm -E %fedora)".noarch.rpm
            sudoless dnf update -y
            sudoless dnf install "${all[@]}" -y
        } &>>"$logFile"
        is_working "$* installed"
    elif [ "$WOS" = "arch" ]; then
        sudoless pacman -S "${all[@]}" --needed --noconfirm &>>"$logFile"
        is_working "$* installed"
    else
        error "Unknow OS: $WOS"
    fi
}

function aur_ins() {
    read -ra all <<<"$@"
    info "Installation: $*"
    if [ "$WOS" = "arch" ]; then
        # Aur tool install
        if pikaur -V &>/dev/null; then
            arch_package_install https://aur.archlinux.org/pikaur.git &>>"$logFile"
        fi
        pikaur -S "${all[@]}" --needed --noconfirm &>>"$logFile"
        is_working "$* installed"
    else
        error "Invalid OS"
    fi
}

function arch_package_install() {
    info "Arch install: $1"
    sudoless pacman -S --needed base-devel git --noconfirm &>>"$logFile"
    tmpD=$(mktemp -d)
    git clone "$1" "$tmpD" &>>"$logFile"
    current_dir=$(pwd)
    cd "$tmpD" || safeExit
    makepkg -fsri --skipinteg --noconfirm &>>"$logFile"
    cd "$current_dir" || safeExit
    rm -rf "$tmpD"
}

function git_clone() {
    info "Cloning $1"
    if [ ! -e "$2" ]; then
        git clone --depth=1 "$1" "$2" &>>"$logFile"
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
    ln -sfn "$LOCAL"/user_conf/zshrc ~/.zshrc
    git_clone https://github.com/ohmyzsh/ohmyzsh ~/.oh-my-zsh
    ln -sfn "$LOCAL"/user_conf/custom.zsh-theme ~/.oh-my-zsh/custom/themes
    sudoless chsh -s /usr/bin/zsh "$USER" &>>"$logFile"
    is_working "Shell changed to zsh"

    # vimrc
    git_clone https://github.com/exocen/vim-conf ~/.vim_runtime
    sh ~/.vim_runtime/install_awesome_vimrc.sh &>>"$logFile"
    cd ~/.vim_runtime || safeExit
    sh ~/.vim_runtime/update.sh &>>"$logFile"
    is_working "Vim installed"
    cd "$LOCAL" || safeExit
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
                    ln -sfn "$LOCAL/user_conf/zprofile" ~/.zprofile
                    conf_folder user_conf/home_conf
                    list=""
                    while IFS= read -r line; do
                        char=$(echo "$line" | head -c1)
                        if [ "$char" != "#" ]; then
                            list="$list $line"
                        fi
                    done <"$file"

                    aur_ins "$list"
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

function ending() {
    # Add status line to log for post-installation check usage
    if $success_state; then
        success "Installation successful"
    else
        error "Installation failed"
    fi
}

function safeExit() {
    # Delete temp files, if any
    if [ -d "${tmpDir}" ]; then
        rm -r "${tmpDir}"
    fi
    trap - INT TERM EXIT
    if [ $# -eq 0 ]; then
        if $printLog; then
            echo -e "$(date +"%T") ${blue}$(printf "[%7s]" "info") "Logfile: "$logFile""${reset}"
        fi
        ending
    fi
    exit

}

# Set Base Variables
# ----------------------
scriptName=$(basename "$0")

# Set Flags
printLog=true
debug=false
noconfirm=false
success_state=true
args=()

# Set Colors
bold=$(tput bold)
reset=$(tput sgr0)
red=$(tput setaf 1)
green=$(tput setaf 76)
yellow=$(tput setaf 3)
blue=$(tput setaf 38)

# Set Temp Directory
tmpDir="/tmp/${scriptName}.$RANDOM.$RANDOM.$RANDOM.$$"
(umask 077 && mkdir "${tmpDir}") || {
    die "Could not create temporary directory! Exiting."
}

# Logging (overwrited by --logpath)
logFile="/tmp/${scriptName}-$(date "+%s").log"

# Options and Usage
usage() {
    printf "%s [OPTION]

    %sOptions:%s
    -d, --debug       Use debug mode
    -l, --logpath     Set log path (default /tmp)
    -n, --noconfirm   Skip all user interaction.  Implied 'No' to all actions.
    -h, --help        Display this help and exit
    \n" "${scriptName}" "${bold}" "${reset}"
}

# Iterate over options breaking -ab into -a -b when needed and --foo=bar into --foo bar
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
# [[ $# -eq 0  ]] && set -- "--help"

# Read the options and set stuff
while [[ $1 = -?* ]]; do
    case $1 in
    -h | --help)
        usage >&2
        safeExit true
        ;;
    -d | --debug) debug=true ;;
    -l | --logpath)
        logFile="$2"
        shift
        ;;
    -n | --noconfirm) noconfirm=true ;;
    --endopts)
        shift
        break
        ;;
    *)
        error "invalid option: '$1'."
        safeExit true
        ;;
    esac
    shift
done

# Store the remaining part as arguments.
args+=("$@")

# Logging & Feedback
function _alert() {
    if [ "${1}" = "error" ]; then local color="${bold}${red}"; fi
    if [ "${1}" = "warning" ]; then local color="${yellow}"; fi
    if [ "${1}" = "success" ]; then local color="${green}"; fi
    if [ "${1}" = "input" ]; then local color="${bold}"; fi
    if [ "${1}" = "info" ]; then local color="${blue}"; fi
    # Don't use colors on pipes or non-recognized terminals
    if [[ "${TERM}" != "xterm"* ]] || [ -t 1 ]; then
        color=""
        reset=""
    fi

    # Print to console when script is not 'debug'
    if [ "${1}" = "debug" ]; then true; else
        echo -e "$(date +"%T") ${color}$(printf "[%7s]" "${1}") ${_message}${reset}"
    fi

    # Print to Logfile
    if ${printLog}; then
        color=""
        reset="" # Don't use colors in logs
        echo -e "$(date +"%F %T") $(printf "[%7s]" "${1}") ${_message}" >>"${logFile}"
        if [ "${1}" = "debug" ]; then
            echo -e "$(date +"%F %T") $(printf "[%7s]" "run") $(${_message} 2>&1)" >>"${logFile}"
        fi
    fi
}

function error() {
    local _message="${*}"
    echo -e "$(_alert error)"
}

function warning() {
    local _message="${*}"
    echo -e "$(_alert warning)"
}

function info() {
    local _message="${*}"
    echo -e "$(_alert info)"
}

function success() {
    local _message="${*}"
    echo -e "$(_alert success)"
}

function input() {
    local _message="${*}"
    echo -n "$(_alert input)"
}

# Seeking confirmation
function seek_confirmation() {
    if ! "${noconfirm}"; then
        input "$@"
        read -rp " (y/N) " -n 1
        echo ""
    fi

}

function is_confirmed() {
    if "${noconfirm}"; then
        return 1
    elif [[ "${REPLY}" =~ ^[Yy]$ ]]; then
        return 0
    fi
    return 1

}

# Set IFS to preferred implementation
IFS=$' \n\t'

# Run in debug mode, if set
if ${debug}; then set -x; fi

trap 'safeExit' ERR
# Bash will remember & return the highest exitcode in a chain of pipes.
# This way you can catch the error in case mysqldump fails in `mysqldump |gzip`, for example.
set -o pipefail

# Run your script
mainScript
# Exit cleanly
safeExit
