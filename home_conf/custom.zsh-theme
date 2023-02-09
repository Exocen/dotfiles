# settings
typeset +H _current_dir="%{$fg_bold[blue]%}%3~%{$reset_color%} "
typeset +H _return_status="%{$fg_bold[red]%}%(?..⍉)%{$reset_color%}"
typeset +H _hist_no="%{$fg[grey]%}%h%{$reset_color%}"

PROMPT='
${_current_dir} $(git_prompt_info) $(git_prompt_status)
%{%(!.${fg[red]}.${fg[white]})%}▶%{$reset_color%} '

PROMPT2='%{%(!.${fg[red]}.${fg[white]})%}◀%{$reset_color%} '

RPROMPT='$(vi_mode_prompt_info)%{$(echotc UP 1)%}$(_user_host)[%*] ${_return_status}%{$(echotc DO 1)%}'

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


MODE_INDICATOR="%{$fg_bold[yellow]%}❮%{$reset_color%}%{$fg[yellow]%}❮❮%{$reset_color%}"

# Git prompt settings
ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[green]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY=" %{$fg[red]%}✗%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_CLEAN=""
ZSH_THEME_GIT_PROMPT_ADDED="%{$fg[green]%}✚ "
ZSH_THEME_GIT_PROMPT_MODIFIED="%{$fg[yellow]%}⚑ "
ZSH_THEME_GIT_PROMPT_DELETED="%{$fg[red]%}✖ "
ZSH_THEME_GIT_PROMPT_RENAMED="%{$fg[blue]%}▴ "
ZSH_THEME_GIT_PROMPT_UNMERGED="%{$fg[cyan]%}§ "
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg[white]%}◒ "

export LSCOLORS="exfxcxdxbxegedabagacad"
export LS_COLORS='di=34;40:ln=35;40:so=32;40:pi=33;40:ex=31;40:bd=34;46:cd=34;43:su=0;41:sg=0;46:tw=0;42:ow=0;43:'
export GREP_COLORS='mt=1;33'
