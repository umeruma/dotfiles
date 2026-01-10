# ~/.zprofile
# Login-shell initializations (run once at login).
# Define helper to safely add paths and set login-scoped envvars.
# 
# read order
# - .zshenv 
# - .zprofile (this file)
# - .zshrc

# -------------------------
# Path / environment setup
# -------------------------
# Ensure path is uniqued
typeset -U path

# DOTFILES bin
if [[ -d "$DOTFILES/bin" ]]; then
    path=("$DOTFILES/bin" $path)
fi

# Add local bin
path=("$HOME/.local/bin" $path)

# Homebrew: put binaries on PATH and export common envs
if [[ -d "/opt/homebrew" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"

    # Add Homebrew completions to fpath (if needed)
    # path=("/opt/homebrew/bin" "/opt/homebrew/sbin" $path)
    # if command -v brew >/dev/null 2>&1; then
    #     fpath=($(brew --prefix)/share/zsh/site-functions $fpath)
    # fi

    # Bundle file
    export HOMEBREW_BUNDLE_FILE="$DOTFILES/macos/Brewfile"
    
    # Avoid installing certain formulae via Homebrew
    # Link: https://docs.brew.sh/Manpage#:~:text=fishcompletion%2C%20zshcompletion%2C%20stageonly.-,HOMEBREW_FORBIDDEN_FORMULAE,-A%20space-separated%20list
    export HOMEBREW_FORBIDDEN_FORMULAE="node python python3 pip npm pnpm yarn claude"
fi

# Rustup in Homebrew prefix (if present)
if [[ -d "/opt/homebrew/opt/rustup/bin" ]]; then
    path=("/opt/homebrew/opt/rustup/bin" $path)
fi

export MISE_STATUS_MESSAGE_SHOW_ENV=true
export MISE_STATUS_MESSAGE_SHOW_TOOLS=true

# -------------------------
# add zsh completions
# -------------------------

# pkgx interactive initialization (if installed)
# if command -v pkgx >/dev/null 2>&1; then
#     eval "$(pkgx --quiet dev --shellcode)"
# fi

# fpath=($HOME/.homesick/repos/homeshick/completions $fpath)
