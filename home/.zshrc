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

# Arrow keys: walk history filtered by what is already typed (omarchy inputrc)
bindkey '^[[A' history-beginning-search-backward
bindkey '^[[B' history-beginning-search-forward
bindkey '^[OA' history-beginning-search-backward
bindkey '^[OB' history-beginning-search-forward

# Completion: case-insensitive, Tab / Shift+Tab cycle candidates (omarchy inputrc)
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
setopt MENU_COMPLETE
bindkey '^[[Z' reverse-menu-complete

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

# =========================
# Tools
# =========================
# One section per tool: delete the section when the tool is removed.
# Sections that eval/PATH are order-sensitive; keep them in this order.

# --- Playdate SDK -------------------------
export PLAYDATE_SDK_PATH="$HOME/Developer/PlaydateSDK"
if [[ -d "$PLAYDATE_SDK_PATH/bin" ]]; then
    path=("$PLAYDATE_SDK_PATH/bin" $path)
fi

# --- sheldon (plugin manager) --------------
if command -v sheldon >/dev/null 2>&1; then
    eval "$(sheldon source)"
fi

# --- mise (pkg manager) -------------------
eval "$(mise activate zsh)"

export MISE_STATUS_MESSAGE_SHOW_ENV=true
export MISE_STATUS_MESSAGE_SHOW_TOOLS=true

# --- zoxide (smarter cd) ------------------
# Replaces enhancd (unmaintained). `cd <query>` jumps by frecency;
# bare `cd` / `cdi` pick from history with fzy, like enhancd did.
if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init zsh --cmd cd)"
    cdi() {
        local dir
        dir="$(zoxide query -l | fzy --prompt '❯ ')" || return
        __zoxide_cd "$dir"
    }
    cd() { if (( $# == 0 )); then cdi; else __zoxide_z "$@"; fi; }
fi

# --- starship (prompt) --------------------
# Replaces pure; one config for zsh and PowerShell (home/.config/starship.toml).
if command -v starship >/dev/null 2>&1; then
    eval "$(starship init zsh)"
fi

# --- git-wt (git worktree manager) --------
# https://github.com/k1LoW/git-wt?tab=readme-ov-file
eval "$(git wt --init zsh)"

wt() {
  local line
  line="$(git wt | tail -n +2 | fzy)" || return
  [[ -n "$line" ]] || return
  git wt "$(printf '%s\n' "$line" | awk '{print $(NF-1)}')"
}

wr() {
  # git-wt で管理されているディレクトリを fzy で選択して削除
  local line
  line="$(git wt | tail -n +2 | fzy)" || return
  [[ -n "$line" ]] || return
  local dir="$(printf '%s\n' "$line" | awk '{print $(NF-1)}')"
  git wt -d "$dir"
}

# ga <branch>: add a worktree and switch to it. gd [branch]: delete it from the main worktree.
ga() { git wt "$@"; }
gd() {
  local target="${1:-$(git branch --show-current)}"
  cd "$(git rev-parse --path-format=absolute --git-common-dir)/.." && git wt -d "$target"
}

export XDG_CONFIG_HOME="$HOME/.config"

# --- fzy (fuzzy finder) -------------------
# Interactive file selection with fzy
fzyselect() {
  fzy < <(find . -maxdepth 1)
}
alias -g F='$(fzyselect)'

# --- fzf (fuzzy finder with preview) ------
# ff: pick a file with a bat preview. eff: open the pick in $EDITOR. (omarchy aliases)
export FZF_DEFAULT_OPTS="--color=16 --layout=reverse --border --height=80%"
ff() { fzf --preview 'bat --style=numbers --color=always {}' "$@"; }
eff() { local f; f="$(ff)" && [[ -n "$f" ]] && "$EDITOR" "$f"; }

# --- Cursor -------------------------------
# Cursor IDE (Editor Window; skip Agents/Glass on launch)
# Note: `cu` is taken by /usr/bin/cu (serial dial-up), so use `cur` instead.
alias cursor='cursor --classic'

# Cursor CLI agent (brew cask cursor-cli)
cua() { cursor-agent "$@"; }

# --- herdr --------------------------------
hr() { herdr "$@"; }
# hdl / hdlm / hsl: dev layouts (editor + agent + terminal), ported from omarchy
[[ -r "$HOME/.config/zsh/herdr.zsh" ]] && source "$HOME/.config/zsh/herdr.zsh"

# --- Neovim -------------------------------
# args pass through; n defaults to . (omarchy alias)
n() { nvim "${@:-.}"; }

# --- lazygit (git UI) ---------------------
lg() { lazygit "${@:-.}"; }

# --- gh (GitHub CLI) ----------------------
# https://cli.github.com/manual/gh_repo_gitignore_view
gi() { gh repo gitignore "$@"; }

# https://cli.github.com/manual/gh_repo_license_view
gli() { gh repo license "$@"; }

# --- Keka ---------------------------------
alias keka="/Applications/Keka.app/Contents/MacOS/Keka --cli"

# =========================
# Shell basics
# =========================
# eza when present (omarchy aliases), plain ls otherwise. No icons: font may lack NF glyphs.
if command -v eza >/dev/null 2>&1; then
    alias ls="eza --group-directories-first"
    alias ll="eza -lh --group-directories-first"
    alias la="eza -lah --group-directories-first"
    alias lt="eza --tree --level=2 --long --git"
else
    alias ls="ls -G"
    alias ll="ls -lG"
    alias la="ls -laG"
fi

# =========================
# dotfiles
# =========================
alias dot='cd $DOTFILES'

dottrack() {
  if [[ -z "$1" ]]; then
    echo "Usage: dottrack <file_or_directory>"
    return 1
  fi

  local target="$HOME/$1"

  # ホームディレクトリに存在するか確認
  if [[ ! -e "$target" ]]; then
    echo "Error: $target does not exist"
    return 1
  fi

  # [dotfiles] にエントリ追加 + 実体を home/ へコピー
  mise -C "$DOTFILES_HOME" dotfiles add --path "$DOTFILES_HOME/mise.dotfiles.toml" --yes --source "home/$1" "$target"

  # 元ファイルを symlink に置換（内容同一なので --force 不要）
  mise -C "$DOTFILES_HOME" dotfiles apply --yes

  echo "✓ Tracked: $1 (entry added to mise.toml [dotfiles])"
}
