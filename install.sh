#!/usr/bin/env sh
export TERM=xterm-256color
WOS=''
LOCAL=$(dirname "$(readlink -f "$0")")

sudoless() {
    # Only use sudo if user is not root
    [ "$(id -u)" -eq 0 ] || set -- command sudo "$@"
    "$@"
}

is_working() {
    # Return cmd correct log + error code
    if [ $? -eq 0 ]; then
        success "$1"
    else
        success_state=false
        error "$1"
    fi
}

detectOS() {
    # OS detection
    if [ -f /etc/os-release ]; then
        # shellcheck source=/dev/null
        . "/etc/os-release"
        WOS="$(echo "$ID" | tr '[:upper:]' '[:lower:]')"
    elif [ -f /etc/lsb-release ]; then
        WOS=$(grep -oP '^DISTRIB_ID=\K.*' /etc/lsb-release | tr '[:upper:]' '[:lower:]')
    elif [ -f /etc/redhat-release ]; then
        WOS="fedora"
    elif [ -f /etc/centos-release ]; then
        WOS="centos"
    elif [ -f /etc/debian_version ]; then
        WOS="debian"
    elif [ -f /etc/arch-release ]; then
        WOS="arch"
    else
        error "Unknown OS exiting"
        safeExit true
    fi
    info "OS detected: $WOS"
}

conf_folder() {
    # copy $LOCAL/$1 dir contents to $USER/.config
    info "Symbolic links to .config"
    mkdir -p ~/.config
    for f in "$LOCAL/$1"/*; do
        DEST=$(basename "$f")
        ln -sfn "$f" ~/.config/"$DEST" 1>>"$logFile" 2>&1
        is_working "ln $f to ~/.config/$DEST"
    done
}

ins() {
    # install $* packages (depends on detectOS() to get $WOS)
    info "Installation: $* "
    if [ "$WOS" = "ubuntu" ] || [ "$WOS" = "debian" ] || [ "$WOS" = "raspbian" ]; then
        sudoless apt update -y 1>>"$logFile" 2>&1
        sudoless apt install "$@" -y 1>>"$logFile" 2>&1
        is_working "$* installed"
    elif [ "$WOS" = "fedora" ]; then
        sudoless yum install "$@" -y 1>>"$logFile" 2>&1
        is_working "$* installed"
    elif [ "$WOS" = "alpine" ]; then
        sudoless apk add shadow 1>>"$logFile" 2>&1
        sudoless apk add "$@" 1>>"$logFile" 2>&1
        is_working "$* installed"
    elif [ "$WOS" = "arch" ] || [ "$WOS" = "manjaro" ]; then
        sudoless pacman -Sy "$@" --needed --noconfirm 1>>"$logFile" 2>&1
        is_working "$* installed"
    else
        error "Unknow OS: $WOS"
    fi
}

aur_ins() {
    # Aur tool install and/or use
    info "Installation: $*"
    if [ "$WOS" = "arch" ]; then
        if ! pikaur -V 1>/dev/null 2>&1; then
            arch_package_install https://aur.archlinux.org/pikaur.git
        fi
        pikaur -S "$@" --needed --noconfirm --noedit 1>>"$logFile" 2>&1
        is_working "$* installed"
    else
        error "Invalid OS"
    fi
}

arch_package_install() {
    # Arch manual install from git link with makepkg
    info "Arch install: $1"
    sudoless pacman -S --needed base-devel git --noconfirm 1>>"$logFile" 2>&1
    tmpD=$(mktemp -d)
    git clone "$1" "$tmpD" 1>>"$logFile" 2>&1
    current_dir=$(pwd)
    cd "$tmpD" || safeExit
    makepkg -fsri --skipinteg --noconfirm 1>>"$logFile" 2>&1
    is_working "$1 installed"
    cd "$current_dir" || safeExit
    rm -rf "$tmpD"
}

git_clone() {
    # Git clone $1 to $2 if $1 not already present
    info "Cloning $1"
    if [ ! -e "$2" ]; then
        git clone --depth=1 "$1" "$2" 1>>"$logFile" 2>&1
        is_working "Cloned: $1 to $2"
    else
        warning "$2 already present"
    fi
}

basic_install() {
    info "Basic installation"
    # Basic packages
    ins vim git htop iftop iotop tree zsh make wget curl sudo rsync

    # zsh
    ln -sfn "$LOCAL"/user_conf/zshrc ~/.zshrc
    git_clone https://github.com/ohmyzsh/ohmyzsh ~/.oh-my-zsh
    ln -sfn "$LOCAL"/user_conf/custom.zsh-theme ~/.oh-my-zsh/custom/themes
    sudoless chsh -s /usr/bin/zsh 1>>"$logFile" 2>&1
    [ "$(cat /etc/passwd | grep ^`whoami`: | cut -d ':' -f7)" = "/usr/bin/zsh" ]
    is_working "Shell changed to zsh"

    # vimrc
    ln -sfn "$LOCAL"/user_conf/vimrc ~/.vimrc
    is_working "Vim installed"
}

dev_env_install() {
    # Arch dev env installation
    if [ "$WOS" = "arch" ] ; then
        if [ "$(id -u)" == 0 ]; then
            info "Dev Env available for non root user"
            safeExit
        fi
        seek_confirmation 'Install Dev Env ?'
        if is_confirmed; then
            {
                file="$LOCAL/arch-package-list"
                if [ -f "$file" ]; then
                    info "Arch dev inv installation"
                    # Specific arch .config
                    ln -sfn "$LOCAL/user_conf/zprofile" ~/.zprofile
                    conf_folder user_conf/home_conf
                    list=""
                    while IFS= read -r line; do
                        char=$(echo "$line" | head -c1)
                        if [ "$char" != "#" ]; then
                            list="$list $line"
                        fi
                    done <"$file"
                    pacman -Si &>/dev/null $list && ins $list || aur_ins $list
                else
                    error "Missing $file"
                fi
            }
        fi
    fi
}

mainScript() {
    info 'Script started'
    if [ -z "$EDITOR" ]; then
        export EDITOR=nano
    fi
    detectOS
    basic_install
    dev_env_install
}

safeExit() {
    # Delete temp files, if any
    if [ -d "${tmpDir}" ]; then
        rm -r "${tmpDir}"
    fi
    trap - INT TERM EXIT
    if [ $# -eq 0 ]; then
        if $printLog; then
            printf "%s%s [%7s] Logfile: %s %s\n" "$(date +'%T')" "$blue" "info" "$logFile" "$reset"
        fi
        # Add status line to log for post-installation check
        if $success_state; then
            success "Installation successful on $WOS"
        else
            error "Installation failed on $WOS"
        fi
    fi
    exit

}

# Set Base Variables
# ----------------------
scriptName=$(basename "$0")

# Set Flags
printLog=true
debug=false
implied_no=false
success_state=true

# Set Colors
bold=$(tput bold 2>/dev/null)
reset=$(tput sgr0 2>/dev/null)
red=$(tput setaf 1 2>/dev/null)
green=$(tput setaf 76 2>/dev/null)
yellow=$(tput setaf 3 2>/dev/null)
blue=$(tput setaf 38 2>/dev/null)

# Set Temp Directory
tmpDir="/tmp/${scriptName}.$(awk 'BEGIN { srand(); print int(rand()*32768) }' /dev/null).$(awk 'BEGIN { srand(); print int(rand()*32768) }' /dev/null).$(awk 'BEGIN { srand(); print int(rand()*32768) }' /dev/null).$$"
(umask 077 && mkdir "${tmpDir}") || {
    die "Could not create temporary directory! Exiting."
}

# Logging (overwrited by --logpath)
logFile="/tmp/${scriptName}-$(date "+%s").log"

# Usage/Help
usage() {
    printf "%s [OPTION]

    %sOptions:%s
    -d     Use debug mode
    -l     Set log path (default /tmp)
    -n     Skip all user interaction.  Implied 'No' to all actions.
    -h     Display this help and exit
    \n" "${scriptName}" "${bold}" "${reset}"
}

# Options
while getopts 'hndl:' opt; do
    case $opt in
    h)
        usage >&2
        safeExit true
        ;;
    d) debug=true ;;
    l) logFile="${OPTARG}" ;;
    n) implied_no=true ;;
    ?)
        echo "invalid option: '$1'."
        usage >&2
        safeExit true
        ;;
    esac
done

# Logging & Feedback
_alert() {
    if [ "${1}" = "error" ]; then color="${bold}${red}"; fi
    if [ "${1}" = "warning" ]; then color="${yellow}"; fi
    if [ "${1}" = "success" ]; then color="${green}"; fi
    if [ "${1}" = "input" ]; then color="${bold}"; fi
    if [ "${1}" = "info" ]; then color="${blue}"; fi

    # Print to console when script is not 'debug'
    if [ "${1}" != "debug" ]; then
        printf "%s%s [%7s] %s %s\n" "$(date +'%T')" "$color" "${1}" "$_message" "$reset"
    fi

    # Print to Logfile
    if ${printLog}; then
        color=""
        reset="" # Don't use colors in logs
        printf "%s%s [%7s] %s %s\n" "$(date +'%F %T')" "$color" "${1}" "$_message" "$reset" >>"${logFile}"
        if [ "${1}" = "debug" ]; then
            printf "%s%s [%7s] %s %s\n" "$(date +'%F %T')" "$color" "run" "$(${_message} 2>&1)" "$reset" >>"${logFile}"
        fi
    fi
}

error() {
    _message="${*}"
    printf "%s\n" "$(_alert error)"
}

warning() {
    _message="${*}"
    printf "%s\n" "$(_alert warning)"
}

info() {
    _message="${*}"
    printf "%s\n" "$(_alert info)"
}

success() {
    _message="${*}"
    printf "%s\n" "$(_alert success)"
}

input() {
    _message="${*}"
    printf "%s\n" "$(_alert input)"
}

# Seeking confirmation
seek_confirmation() {
    if ! "${implied_no}"; then
        input "$1 (y/N)"
        read -r REPLY
        REPLY=$(echo "$REPLY" | cut -c 1 | tr '[:upper:]' '[:lower:]')
        echo ""
    fi
}

is_confirmed() {
    if ! "${implied_no}" && [ "${REPLY}" = "y" ]; then
        return 0
    fi
    return 1
}

# Run in debug mode, if set
if ${debug}; then set -x; fi

# Run your script
mainScript
# Exit cleanly
safeExit
