# ~/.bashrc

# --- Retro ThinkPad Prompt ---
# Definir colores (basados en el esquema que pusimos en Alacritty)
GREEN="\[\033[0;32m\]"
CYAN="\[\033[0;36m\]"
WHITE="\[\033[0;37m\]"
DIM="\[\033[2m\]"
RESET="\[\033[0m\]"

[[ $- != *i* ]] && return

export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.local/bin/statusbar:$PATH"

alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias q='exit'
alias t='tmux'
alias v='nvim'
alias vim='nvim'
alias sx='startx'
alias ls='exa -h --icons --git'
alias la='ls -la'
alias ta='tmux a'
alias td='tmux detach'
alias r='ranger'
alias sx='startx'
alias spotify='ncspot'

alias bat-save='thinkbat 75 80'
alias bat-full='thinkbat 95 100'
alias bat-status='cat /sys/class/power_supply/BAT0/status && grep . /sys/class/power_supply/BAT0/charge_control_*_threshold '

export EDITOR=nvim
export VISUAL=nvim

#PS1='[\u@\h \W]\$ '
PS1="\[\e[38;5;240m\]\w \[\e[38;5;236m\]† \[\e[0m\]"

thinkbat() {
  local start=$1
  local end=$2

  if [[ -z "$start" || -z "$end" ]]; then
    echo "Use: thinkbat [inicio] [fin]"
    return 1
  fi

  if [ "$end" -gt 80 ]; then
    sudo bash -c "echo $end > /sys/class/power_supply/BAT0/charge_control_end_threshold"
    sudo bash -c "echo $start > /sys/class/power_supply/BAT0/charge_control_start_threshold"
  else
    sudo bash -c "echo $start > /sys/class/power_supply/BAT0/charge_control_start_threshold"
    sudo bash -c "echo $end > /sys/class/power_supply/BAT0/charge_control_end_threshold"
  fi

  echo "Configured: Start $start% / End $end%"
}

if [ "$LC_BOOX_MODE" == "1" ]; then
  set background-light
  export TERM=xterm-mono
  export VIM_EINK=1
fi
