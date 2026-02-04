#!/usr/bin/env zsh

emulate -L zsh
set -eu
set -o pipefail

source "${0:A:h}/_lib.zsh"

local root
root=$(repo_root)
cd "$root"

require_cmd stow

print -r -- '==> Start to deploy dotfiles to home directory.'
stow -v -d "$root" -t ~ home
