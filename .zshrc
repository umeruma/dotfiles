# ~/.zshrc
# Interactive-shell configuration (aliases, completion, prompt, plugins).
# 
# read order
# - .zshenv 
# - .zprofile
# - .zshrc    (this file)

# -------------------------
# compinit
# -------------------------
# (added by compinstall)
zstyle :compinstall filename '~/.zshrc'

# Initialize zsh completion system
autoload -Uz compinit && compinit

# -------------------------
# Shell behaviour / options
# -------------------------
# Zsh option: Keybindings (use emacs keybindings)
bindkey -e

# Zsh builtin module: zmv (small utility)
autoload -Uz zmv
alias zmv='noglob zmv -W'

# Zsh option: History
# based on https://github.com/sorin-ionescu/prezto/blob/master/modules/history/init.zsh
setopt BANG_HIST
setopt EXTENDED_HISTORY
setopt SHARE_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_SAVE_NO_DUPS
setopt HIST_VERIFY
setopt HIST_BEEP
HISTFILE="$HOME/.histfile"
HISTSIZE=10000
SAVEHIST=$HISTSIZE

# Zsh option: Directory
# based on https://github.com/sorin-ionescu/prezto/blob/master/modules/directory/init.zsh
# setopt AUTO_CD
# setopt AUTO_PUSHD
# setopt PUSHD_IGNORE_DUPS
# setopt PUSHD_SILENT
# setopt PUSHD_TO_HOME
# setopt CDABLE_VARS
# setopt MULTIOS
# setopt EXTENDED_GLOB
# unsetopt CLOBBER 

# -------------------------
# Development Environment
# -------------------------
# Playdate SDK
export PLAYDATE_SDK_PATH="$HOME/Developer/PlaydateSDK"
if [[ -d "$PLAYDATE_SDK_PATH/bin" ]]; then
    path=("$PLAYDATE_SDK_PATH/bin" $path)
fi

# -------------------------
# Plugin options & Plugin managers
# -------------------------
# enhancd / fzf integration
export ENHANCD_FILTER="fzf --height 50% --reverse --ansi"
export ENHANCD_DOT_SHOW_FULLPATH=1

# sheldon (plugin manager)
# Ensure SHELDON is installed; this eval is interactive-only
if command -v sheldon >/dev/null 2>&1; then
    eval "$(sheldon source)"
fi

# -------------------------
# Aliases & small functions
# -------------------------
gi() { curl -L -s "https://www.gitignore.io/api/$@" ;}

alias ls="ls -G"
alias ll="ls -lG"
alias la="ls -laG"

alias -g F='$(fzf)'