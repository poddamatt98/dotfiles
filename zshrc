#!/bin/zsh

precmd() {
    if [ -d .git ]; then
        PS1=" %F{white}🔥 %F{cyan}%~ %F{green}$(git rev-parse --abbrev-ref HEAD 2>/dev/null)%f %F{cyan}➜ %f "
    else
        PS1=" %F{white}🔥 %F{cyan}%~%f %F{cyan}➜ %f "
    fi
}


set_variables() {
  export PODDAMAT_CONFIG="set"
  export PROJECTS_PATH=$HOME
}

set_bindings() {
  bindkey -s ^f "$HOME/.config/scripts/my_tmux.sh\n"
}

precmd
set_variables
set_bindings
