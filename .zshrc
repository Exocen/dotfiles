#ZSH_THEME="CUSTOM_afowler" # Optionally, set this to "random"
CASE_SENSITIVE="false"
DISABLE_AUTO_UPDATE="TRUE"
DISABLE_LS_COLORS="false"
DISABLE_AUTO_TITLE="false"
COMPLETION_WAITING_DOTS="true"

# Example format: plugins=(rails git textmate ruby lighthouse)

zstyle ':completion:*' menu select
compctl -/ cd # type a directory's name to cd to it.
eval `dircolors -b`

autoload -U compinit
compinit
autoload -U promptinit
promptinit
# autoload predict-on
# predict-on
autoload -U colors # add some color

setopt autopushd pushdminus pushdsilent pushdtohome
setopt autocd
setopt cdablevars
#setopt ignoreeof              # don't ignore ^D EOF
setopt interactivecomments
setopt nobanghist
setopt noclobber
setopt SH_WORD_SPLIT
setopt nohup
setopt extendedglob
setopt correct
setopt NO_RM_STAR_SILENT

# History stuff
setopt HIST_REDUCE_BLANKS
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS
HISTSIZE=1000
SAVEHIST=1000
HISTFILE=~/.zsh_history

# Vars used later on by zsh
export EDITOR="emacs -nw"
export SVN_EDITOR="emacs -nw"
export BROWSER=google-chrome-stable
export TERM=xterm-256color
export PATH=$PATH:~/.opam/4.00.1/bin:~/.opam/bin/

#ohmyzsh !
export ZSH=$HOME/.oh-my-zsh
ZSH_THEME="fino-time"
plugins=(git symfony2)

source $ZSH/oh-my-zsh.sh

# User configuration omz

#export PATH=$HOME/bin:/usr/local/bin:$PATH


compinit -C
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# allow approximate
zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*:match:*' original only
zstyle ':completion:*:approximate:*' max-errors 1 numeric

# tab completion for PID :D
zstyle ':completion:*:*:kill:*' menu yes select
zstyle ':completion:*:kill:*' force-list always

# cd not select parent dir.
zstyle ':completion:*:cd:*' ignore-parents parent pwd

# Key bindings
typeset -g -A key
bindkey '^?' backward-delete-char
bindkey '^[[1~' beginning-of-line
bindkey '^[[5~' up-line-or-history
bindkey '^[[3~' delete-char
bindkey '^[[4~' end-of-line
bindkey '^[[6~' down-line-or-history
bindkey '^[[A' up-line-or-search
bindkey '^[[D' backward-char
bindkey '^[[B' down-line-or-search
bindkey '^[[C' forward-char

# Set up auto extension stuff
alias -s html=$BROWSER
alias -s org=$BROWSER
alias -s php=$BROWSER
alias -s com=$BROWSER
alias -s net=$BROWSER
alias -s png=comix
alias -s jpg=comix
alias -s gif=comix
alias -s svg=comix
alias -s mkv=vlc
alias -s mp4=vlc
alias -s avi=vlc
alias -s mp3=vlc
alias -s sxw=soffice
alias -s doc=soffice
alias -s gz=tar xzf
alias -s bz2=tar xjf
alias -s zip=unzip
alias -s java=$EDITOR
alias -s py=$EDITOR
alias -s txt=$EDITOR
alias -s PKGBUILD=$EDITOR
alias -s jar=java -jar

# Utilities aliases
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'
alias ll='ls -lFh --group-directories-first --color=auto'
alias la='ls -Ah  --group-directories-first'
alias lla='ls -AlFh --group-directories-first'
alias l='ls -CFh  --group-directories-first'
alias ltex='ll | grep .tex'
alias cl='clear'
alias cp='cp -vi'
alias s='cd ..'
alias dudu='du -hd1 | sort -h'
#alias rm='rm -i'
alias rmi='rm -iv --preserve-root'
alias trash='mkdir -pv ~/.Trash && mv -fv --target-directory=$HOME/.Trash'
alias af='ll ~/.Trash'
alias cmt='rm -rIv ~/.Trash/* ~/.Trash/.*~'
alias rmt='find . -name "*~" -exec rm {} \; -print -or -name ".*~" -exec rm {} \; -print -or -name "\#*\#*" -exec rm {} \; -print'
alias rmte='find . -empty -type d'
alias rmted='find . -empty -type d -delete -print'
alias rst='mkdir -pv po && mv -iv ~/.Trash/* ~/po'
alias x='exit'
alias sx='startx'
alias finame="find * -iname "
alias kbfr='setxkbmap fr'
alias kbus='setxkbmap us'
alias kbdv='setxkbmap dvorak'
alias kb2='setxkbmap -option "ctrl:swapcaps"'
alias dvorak='dvorak7m'
alias j='jobs'
alias m='make'
alias k='killall'
alias pend='sudo pm-suspend'
alias nate='sudo pm-hibernate'
alias brid='sudo pm-hybrid'
alias down='sudo poweroff'
alias boot='sudo reboot'
alias lgt='pkill KILL -U'
alias ff='firefox'
alias cc='chromium-browser --proxy-auto-detect'
alias ch='google-chrome-stable'
alias py='python3'
alias ipy='ipython3'
alias pl='perl -d -e 1'
alias pdflatex='mkdir -p tmp/; pdflatex --output-directory=tmp/'
alias jar='java -jar'
alias -s pdf='evince'
alias am='alsamixer'
alias em='emacs -nw'
alias xem='sudo emacs -nw'
alias iftop='sudo iftop'
alias ifconfig='sudo ifconfig'
alias powertop='sudo powertop'
alias -g S='&> /dev/null &'
alias tre='tree -C --dirsfirst'
alias rmcache='sudo rm -rf ~/.cache/'
alias opvpnp='cd ~/.config/vpn/exo_vps_proxy/ && sudo openvpn --config client.conf --writepid /var/run/vpnc/openvpn.pid'
alias opvpn='cd ~/.config/vpn/exo_vps/ && sudo openvpn --config client.conf --writepid /var/run/vpnc/openvpn.pid'
alias fuspaces='for f in *\ *; do mv "$f" "${f// /_}"; done '
alias rvminstall='curl -L get.rvm.io | bash -s stable'
alias grubconf='sudo grub2-mkconfig -o /boot/grub2/grub.cfg'

# Archives goodies...
alias tarxz='tar xJvf'
#alias targz='tar xvf'
alias targz='tar czvf'
alias tarbz='tar xjvf'
#alias ungz='tar xvf'
alias ungz='tar xzvf'
alias unbz='tar xjvf'

# dpkg...
alias dbi='sudo dpkg -i'
alias dbr='sudo dpkg -r'

# git...
alias clone='git clone'
alias pull='git pull'
alias add='git add --all'
alias remote='git remote add origin'
alias push='git push'
alias status='git status'
alias commit='git commit -am'
alias forget='git update-index --assume-unchanged'
alias track='git update-index --no-assume-unchanged'
alias checkout='git checkout'
alias gclean='git clean -idx'

#dnf
alias dnf='sudo dnf'
alias distclean='sudo dnf clean all'
alias distsync='sudo dnf distro-sync'
alias fek='fedora-easy-karma --fas-username=rorgoroth'
alias install='sudo dnf install'
alias pkgclean='sudo dnf remove $(package-cleanup --leaves)'
alias remove='sudo dnf erase'
alias search='sudo dnf search'
alias show='sudo dnf info'
alias update='sudo dnf check-update'
alias upgrade='sudo dnf upgrade'
alias openvpnconf='sudo openvpn --config'
alias railsinstall='curl -L get.rvm.io | bash -s stable --rails'

function reset() {
    # # saving work before reset
    # git commit -a -m "Saving my work, just in case"
    # git branch my-saved-work

    git fetch origin
    git reset --hard origin/master
}
function git_config() {
    git config credential.helper store
    git config --global user.mail kureijy@gmail.com
    git config --global user.name "Exocen"

    # git config --unset credential.helper # resume password check
}

# systemd...
alias dlist='systemctl -a'
alias dunits='systemctl list-units'
alias dsockets='systemctl list-sockets'
alias dstatus='systemctl status'
alias dstart='sudo systemctl start'
alias dstop='sudo systemctl stop'
alias denable='sudo systemctl enable'
alias ddisable='sudo systemctl disable'
alias dreload='sudo systemctl reload'
alias drestart='sudo systemctl restart'

# apt-get...
alias apu='sudo aptitude update'
alias appg='sudo aptitude upgrade'
alias apd='sudo aptitude dist-upgrade'
alias apugd='sudo aptitude -y update && sudo aptitude -y upgrade && sudo aptitude -y dist-upgrade'
alias api='sudo aptitude install'
alias apie='sudo aptitude install -t experimental'
alias apr='sudo aptitude remove'
alias app='sudo aptitude purge'
alias apar='sudo aptitude autoremove'
alias apcc='sudo aptitude clean && sudo aptitude autoclean'
alias apsearch='apt-cache search'
alias aps='apt-cache search'
alias apse='apt-cache search -t experimental'
alias apshow='apt-cache showpkg'

# yum
alias yu='sudo yum update --color=always'
alias ys='yum search --color=always'
alias yi='sudo yum install --color=always'
alias yr='sudo yum autoremove --color=always'
alias yc='sudo yum clean all --color=always'

# sbt
alias t='java -jar ~/Scripts/sbt-launch.jar'
alias sbt='java -jar ~/Scripts/sbt-launch.jar'

# scala
alias sc='cd /tmp/ && java -jar ~/Scripts/sbt-launch.jar console'

# My functions
function lk() {
    grep -rHsni "$1" .
}

function del(){
    mv -f $@ /tmp/
}

function c() {
    # builtin cd "$*"
    cd $1
    ls -CFh  --group-directories-first
}

function dkill() {
    mykill=`ps -ef | grep $1 | awk '{print $2}'`
    kill -9 $mykill 2> /dev/null
}

function tarl() {
    case $1 in
        *tar.gz)
            tar -tvf $1
            ;;
        *)
            echo "Todo"
            ;;
    esac
}

function untar() {
    case $1 in
        *tar.xz|*.txz|*.xz)
            tar xJvf $1
            ;;
        *.tar.gz|*.tgz|*.gz|*.tar)
            tar xvf $1
            ;;
        *.tar.bz2|*.tbz2*.bz2)
            tar xjvf $1
            ;;
        *.zip)
            unzip $1
            ;;
        *.rar)
            unrar e $1
            ;;
        *.ace)
            unace e $1
            ;;
        *)
            echo "Archive not supported by this awesome function !"
            # exit;;
    esac
}

# remplaced by fuspaces
# function repl(){
#     for file in $@; do mv "$file" `echo $file | tr ' ' '_'` ; done
# }

function eproxy() {
    export https_proxy="https://cacheserv2.univ-lille1.fr:3128"
    export http_proxy="http://cacheserv2.univ-lille1.fr:3128"
    export ftp_proxy="http://cacheserv2.univ-lille1.fr:3128"
    export sftp_proxy="http://cacheserv2.univ-lille1.fr:3128"
    export npm_config_proxy="http://cacheserv2.univ-lille1.fr:3128"
    export npm_config_https_proxy="https://cacheserv2.univ-lille1.fr:3128"
    export ALL_PROXY=$http_proxy

    # export https_proxy="https://proxy.univ-lille1.fr:3128"
    # export http_proxy="http://proxy.univ-lille1.fr:3128"
    # export ftp_proxy="http://proxy.univ-lille1.fr:3128"

    # export https_proxy="https://cacheserv3.univ-lille1.fr:3128"
    # export http_proxy="http://cache-etu.univ-lille1.fr:3128"
    # export ftp_proxy="http://cache-etu.univ-lille1.fr:3128"

}

function unproxy() {
    unset http_proxy
    unset https_proxy
    unset npm_config_proxy
    unset npm_config_https_proxy
    unset ftp_proxy
    unset sftp_proxy
    unset ALL_PROXY
}

export PATH="$PATH:$HOME/.rvm/bin" # Add RVM to PATH for scripting
# rpm local with dependencies use yum
