# ~/.zshrc
# Interactive-shell configuration (aliases, completion, prompt, plugins).
# 
# read order
# - .zshenv 
# - .zprofile
# - .zshrc    (this file)

# compinit (added by compinstall)
# zstyle :compinstall filename '~/.zshrc'

# -------------------------
# Helper functions & utils
# -------------------------
# addToPath: prepend $1 if not already present
addToPath() {
    case ":$PATH:" in
        # already present: move to front
        *":$1:"*) PATH="$1:${PATH/:$1/}" ;;
        # not present: prepend
        *) PATH="$1:$PATH" ;;
    esac
}

# Zsh builtin module: zmv (small utility)
autoload -Uz zmv
alias zmv='noglob zmv -W'

# -------------------------
# Path / environment setup
# -------------------------
# DOTFILES bin
if [[ -d "$DOTFILES/bin" ]]; then
    addToPath "$DOTFILES/bin"
fi

# Add local bin
addToPath "$HOME/.local/bin"

# Homebrew: put binaries on PATH and export common envs
if [[ -d "/opt/homebrew" ]]; then
    addToPath /opt/homebrew/bin
    addToPath /opt/homebrew/sbin

    export HOMEBREW_PREFIX="/opt/homebrew"
    export HOMEBREW_CELLAR="/opt/homebrew/Cellar"
    export HOMEBREW_REPOSITORY="/opt/homebrew"
    export HOMEBREW_BUNDLE_FILE="$HOME/.dotfiles/macos/Brewfile"

    export MANPATH="/opt/homebrew/share/man${MANPATH:+:$MANPATH}:"
    export INFOPATH="/opt/homebrew/share/info:${INFOPATH:-}"
fi

# Rustup in Homebrew prefix (if present)
if [[ -d "/opt/homebrew/opt/rustup/bin" ]]; then
    addToPath /opt/homebrew/opt/rustup/bin
fi

# Playdate SDK (interactive tools)
export PLAYDATE_SDK_PATH="$HOME/Developer/PlaydateSDK"
if [[ -d "$PLAYDATE_SDK_PATH/bin" ]]; then
    addToPath "$PLAYDATE_SDK_PATH/bin"
fi

# enhancd / fzf integration for interactive use
export ENHANCD_FILTER="fzf --height 50% --reverse --ansi"
export ENHANCD_DOT_SHOW_FULLPATH=1

# -------------------------
# add zsh completions + compinit
# -------------------------
# Homebrew zsh completions
if command -v brew >/dev/null 2>&1; then
    eval "$(brew shellenv)"
fi

# pkgx interactive initialization (if installed)
if command -v pkgx >/dev/null 2>&1; then
    eval "$(pkgx --quiet dev --shellcode)"
fi

# Initialize zsh completion system
autoload -Uz compinit && compinit

# -------------------------
# Shell behaviour / options
# -------------------------
# Zsh option: Keybindings (use emacs keybindings)
bindkey -e

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
# Plugin managers
# -------------------------
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