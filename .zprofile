# ~/.zprofile
# Login-shell initializations (run once at login).
# Define helper to safely add paths and set login-scoped envvars.
# 
# read order
# - .zshenv 
# - .zprofile (this file)
# - .zshrc

# -------------------------
# Helper functions
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
    
    export HOMEBREW_BUNDLE_FILE="$HOME/.dotfiles/macos/Brewfile"
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