#!/bin/zsh
zmodload zsh/datetime

my_preexec() {
    cmd_start=$EPOCHSECONDS
}

my_precmd() {
    # --- Exit code indicator ---
    local exit_code=$?
    local status_icon="%F{red}%f"
    (( exit_code == 0 )) && status_icon="%F{green}%f"
    
    # --- Separator ---
    print -P "%F{240}${(l:$COLUMNS::-:)}%f"
    
    local duration=""
    if [[ -n $cmd_start ]]; then
        local elapsed=$(( EPOCHSECONDS - cmd_start ))
        if (( elapsed > 2 )); then
            duration="%F{yellow}${elapsed}s%f"
        fi
        unset cmd_start
    fi
    
    
    # --- Python env ---
    local env_info=""
    if [[ -n "$VIRTUAL_ENV" ]]; then
        env_dir="$(dirname $VIRTUAL_ENV)"
        env_info="%F{blue} $(basename $env_dir)%f"
    fi

    # --- AWS profile ---
    local aws_info=""
    if [[ -n "${AWS_PROFILE:-$AWS_DEFAULT_PROFILE}" ]]; then
        aws_info="%F{208} ${AWS_PROFILE:-$AWS_DEFAULT_PROFILE}%f"
    fi
    
    # --- Git branch + dirty ---
    local git_info=""
    if git rev-parse --is-inside-work-tree &>/dev/null; then
        local branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
        local dirty=""
        [[ -n $(git status --porcelain 2>/dev/null) ]] && dirty="%F{red}*%f"
        git_info="%F{green}󰘬 ${branch}${dirty}%f"

    fi
    
    # --- Assemble ---
    first_line="%F{cyan}%~%f"
    if [[ -n "$git_info" ]]; then
        first_line+=" | ${git_info}"
    fi
    if [[ -n "$env_info" ]]; then
        first_line+=" | ${env_info}"
    fi
    if [[ -n "$aws_info" ]]; then
        first_line+=" | ${aws_info}"
    fi
    first_line+=" | ${status_icon}"
    if [[ -n "$duration" ]]; then
        first_line+=" ${duration}"
    fi
    first_line+="
"
    
    PS1="${first_line} "
}


set_variables() {
  export PODDAMAT_CONFIG="set"
  export PROJECTS_PATH=$HOME
}

set_bindings() {
  bindkey -s ^f "$HOME/.config/scripts/my_tmux.sh\n"
}

set_aliases() {
    alias zshrcrl="source ~/.zshrc"
}

preexec_functions+=(my_preexec)
precmd_functions+=(my_precmd)
set_variables
set_bindings
set_aliases

# fix autocompletion on : for cppman
# https://github.com/aitjcize/cppman#:~:text=Q%3A%20Why%20is%20bash%20completion%20is%20not%20working%20properly%20with%20%3A%3A%3F
export COMP_WORDBREAKS="${COMP_WORDBREAKS//:}"
