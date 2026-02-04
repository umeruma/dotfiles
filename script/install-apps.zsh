#!/usr/bin/env zsh

emulate -L zsh
set -eu
set -o pipefail

source "${0:A:h}/_lib.zsh"

local root uname_s
root=$(repo_root)
cd "$root"

uname_s=$(uname -s)

if [[ "$uname_s" == "Linux" ]]; then
  require_cmd brew
  brew bundle --file=./linux/Brewfile

  if command -v apt-get >/dev/null 2>&1; then
    sudo apt-get install hugo
  else
    print -u2 -r -- "warn: apt-get not found; skipping 'sudo apt-get install hugo'"
  fi
elif [[ "$uname_s" == "Darwin" ]]; then
  require_cmd brew
  brew bundle --file=./macos/Brewfile
else
  print -u2 -r -- "error: unsupported OS: $uname_s"
  exit 1
fi
