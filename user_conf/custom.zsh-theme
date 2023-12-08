# settings
# if character not in range -> /etc/locale.gen -> locale-gen
typeset +H _current_dir="%{%(?.${fg_bold[blue]}.${fg_bold[red]})%}%3~%{$reset_color%} "
typeset +H _hist_no="%{$fg[grey]%}%h%{$reset_color%}"

PROMPT=' ${_current_dir}$(prompt_git)$(_is_root)'
RPROMPT='$(_user_host)[%*]'

function err_indicator(){
    echo "%{%(?.${fg[white]}.${fg[red]})%}$%{$reset_color%}"
}
function _is_root() {
    if [ "$EUID" -eq 0 ]; then
        echo -n "%{$fg_bold[red]%}root%{$reset_color%} "
    fi
}

function _user_host() {
    local me
    if [[ -n $SSH_CONNECTION ]]; then
        me="%n@%m"
    elif [[ $LOGNAME != $USERNAME ]]; then
        me="%n"
    fi
    if [[ -n $me ]]; then
        echo "%{$fg[cyan]%}$me%{$reset_color%} "
    fi
}

prompt_git() {
    local PL_BRANCH_CHAR
    () {
    local LC_ALL="en_US.UTF-8" LC_CTYPE="en_US.UTF-8"
    PL_BRANCH_CHAR=$'\ue0a0'
}
local ref dirty mode repo_path

if [[ "$(git rev-parse --is-inside-work-tree 2>/dev/null)" = "true" ]]; then
    repo_path=$(git rev-parse --git-dir 2>/dev/null)
    dirty=$(parse_git_dirty)
    ref=$(git symbolic-ref HEAD 2> /dev/null) || ref="➦ $(git rev-parse --short HEAD 2> /dev/null)"

    local ahead behind
    ahead=$(git log --oneline @{upstream}.. 2>/dev/null)
    behind=$(git log --oneline ..@{upstream} 2>/dev/null)
    if [[ -n "$ahead" ]] && [[ -n "$behind" ]]; then
        PL_BRANCH_CHAR=$'\u21c5'
    elif [[ -n "$ahead" ]]; then
        PL_BRANCH_CHAR=$'\u21b1'
    elif [[ -n "$behind" ]]; then
        PL_BRANCH_CHAR=$'\u21b0'
    fi


    if [[ -e "${repo_path}/BISECT_LOG" ]]; then
        mode=" <B>"
    elif [[ -e "${repo_path}/MERGE_HEAD" ]]; then
        mode=" >M<"
    elif [[ -e "${repo_path}/rebase" || -e "${repo_path}/rebase-apply" || -e "${repo_path}/rebase-merge" || -e "${repo_path}/../.dotest" ]]; then
        mode=" >R>"
    fi

    setopt promptsubst
    autoload -Uz vcs_info

    zstyle ':vcs_info:*' enable git
    zstyle ':vcs_info:*' get-revision true
    zstyle ':vcs_info:*' check-for-changes true
    zstyle ':vcs_info:*' stagedstr '✚'
    zstyle ':vcs_info:*' unstagedstr '±'
    zstyle ':vcs_info:*' formats ' %u%c'
    zstyle ':vcs_info:*' actionformats ' %u%c'
    vcs_info
    if [[ -n $dirty ]]; then
        echo -n "%{$fg[yellow]%}"
    else
        echo -n "%{$fg[green]%}"
    fi
    echo -n "${${ref:gs/%/%%}/refs\/heads\//$PL_BRANCH_CHAR }${vcs_info_msg_0_%% }${mode}%{$reset_color%} "
fi
}
