# ~/.zprofile
# Login-shell initializations (run once at login).
# PATH itself is declared in .zshenv (agents' shells skip this file).
#
# read order
# - .zshenv
# - .zprofile (this file)
# - .zshrc

# -------------------------
# Path / environment setup
# -------------------------
# Homebrew env for interactive use (HOMEBREW_PREFIX, fpath, INFOPATH)
if [[ -x "/opt/homebrew/bin/brew" ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# /etc/zprofile's path_helper moved system dirs ahead; restore our order.
path=($dotfiles_path $path)

# -------------------------
# add zsh completions
# -------------------------

# pkgx interactive initialization (if installed)
# if command -v pkgx >/dev/null 2>&1; then
#   eval "$(pkgx --quiet dev --shellcode)"
# fi

# fpath=($HOME/.homesick/repos/homeshick/completions $fpath)
