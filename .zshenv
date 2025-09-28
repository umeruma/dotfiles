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
export READNULLCMD="less"

export DOTFILES="$HOME/.dotfiles"
