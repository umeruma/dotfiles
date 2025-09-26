# ~/.zshenv
# Lightweight environment variables (read on every zsh start).
# Avoid running external commands here.
# 
# read order
# - .zshenv   (this file)
# - .zprofile
# - .zshrc
# LINK: https://zsh.sourceforge.io/Doc/Release/Files.html#Files

export LANG=en_US.UTF-8
export EDITOR=nano
export VISUAL="$EDITOR"
export DOTFILES="$HOME/.dotfiles"

# FIXME: maybe no need in future
# Volta (toolchain manager) path so non-interactive tooling can find it
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin${PATH:+:$PATH}"
