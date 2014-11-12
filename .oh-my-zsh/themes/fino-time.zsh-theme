# fino-time.zsh-theme

# Use with a dark background and 256-color terminal!
# Meant for people with RVM and git. Tested only on OS X 10.7.

# You can set your computer name in the ~/.box-name file if you want.

function virtualenv_info {
    [ $VIRTUAL_ENV ] && echo '('`basename $VIRTUAL_ENV`') '
}

local color_status="%(?:%{$FG[040]%}:%{$fg[red]%}%s)"

function prompt_char {
    echo '${color_status} %{$reset_color%}'
}

function box_name {
    [ -f ~/.box-name ] && cat ~/.box-name || hostname -s
}

#local rvm_ruby='‹$(rvm-prompt i v g)›%{$reset_color%}'
local current_dir='${PWD/#$HOME/~}'
local git_info='$(git_prompt_info)'

PROMPT="${color_status}╭─%n %{$reset_color%}@ %{$FG[033]%}$(box_name)%{$reset_color%} in %{$terminfo[bold]$FG[226]%}${current_dir}%{$reset_color%}${git_info}${git_status} %D - %*
${color_status}╰─○%{$reset_color%}$(virtualenv_info)$(prompt_char)"

ZSH_THEME_GIT_PROMPT_PREFIX=" %{$FG[240]%}[%{$FG[014]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$FG[240]%}]%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$FG[001]%} ✘"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$FG[040]%} ✔"
ZSH_THEME_GIT_PROMPT_ADDED="%{$fg[green]%}+"
ZSH_THEME_GIT_PROMPT_MODIFIED="%{$fg[magenta]%}!"
ZSH_THEME_GIT_PROMPT_DELETED="%{$fg[red]%}-"
ZSH_THEME_GIT_PROMPT_RENAMED="%{$fg[blue]%}>"
ZSH_THEME_GIT_PROMPT_UNMERGED="%{$fg[cyan]%}#"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg[yellow]%}?"
