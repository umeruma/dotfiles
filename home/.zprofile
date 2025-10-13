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
fi

# Rustup in Homebrew prefix (if present)
if [[ -d "/opt/homebrew/opt/rustup/bin" ]]; then
    path=("/opt/homebrew/opt/rustup/bin" $path)
fi

# -------------------------
# add zsh completions
# -------------------------

# pkgx interactive initialization (if installed)
if command -v pkgx >/dev/null 2>&1; then
    eval "$(pkgx --quiet dev --shellcode)"
fi