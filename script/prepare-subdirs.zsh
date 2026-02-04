#!/usr/bin/env zsh

emulate -L zsh
set -eu
set -o pipefail

source "${0:A:h}/_lib.zsh"

local root
root=$(repo_root)
cd "$root"

print -r -- '==> Ensure required subdirectories exist (from .deploy_subdir)'

if [[ -f .deploy_subdir ]]; then
  while IFS= read -r path; do
    # Skip blank lines and comments (leading/trailing whitespace allowed)
    [[ "$path" =~ '^[[:space:]]*$' ]] && continue
    [[ "$path" =~ '^[[:space:]]*#' ]] && continue

    # Trim leading/trailing whitespace
    path=${path#${path%%[![:space:]]*}}
    path=${path%${path##*[![:space:]]}}

    mkdir -p "$HOME/$path"
    print -r -- "  mkdir -p $HOME/$path"
  done < .deploy_subdir
else
  print -r -- '  (skip) .deploy_subdir not found'
fi
