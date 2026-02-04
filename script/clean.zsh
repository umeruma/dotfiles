#!/usr/bin/env zsh

emulate -L zsh
set -eu
set -o pipefail

source "${0:A:h}/_lib.zsh"

local root
root=$(repo_root)
cd "$root"

require_cmd stow

print -r -- "Clean dot files in your home directory..."
stow -D -v -d "$root" -t ~ home
