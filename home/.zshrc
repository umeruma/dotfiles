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
setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT
setopt PUSHD_TO_HOME
setopt CDABLE_VARS
setopt MULTIOS
setopt EXTENDED_GLOB
unsetopt CLOBBER 

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
# enhancd / fzy integration
export ENHANCD_FILTER="fzy --prompt '❯ '"
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

# Interactive file selection with fzy
fzyselect() {
  fzy < <(find . -maxdepth 1)
}
alias -g F='$(fzyselect)'

alias dot='cd $DOTFILES'

dottrack() {
  if [[ -z "$1" ]]; then
    echo "Usage: dottrack <file_or_directory>"
    return 1
  fi

  local target="$HOME/$1"
  local dest="$DOTFILES_HOME/home/$1"

  # ホームディレクトリに存在するか確認
  if [[ ! -e "$target" ]]; then
    echo "Error: $target does not exist"
    return 1
  fi

  # 親ディレクトリを作成
  mkdir -p "$(dirname "$dest")"

  # ファイル/ディレクトリを移動
  mv "$target" "$dest"

  # stow でシンボリックリンクを作成
  stow -d "$DOTFILES_HOME" -t "$HOME" home

  echo "✓ Tracked: $1"
}

