#!/usr/bin/env zsh

emulate -L zsh
set -eu
set -o pipefail

source "${0:A:h}/_lib.zsh"

local root uname_s
root=$(repo_root)
cd "$root"

uname_s=$(uname -s)

if [[ "$uname_s" == "Darwin" ]]; then
  open ./macos/BirdsOfParadise.terminal
else
  print -r -- "(skip) theme: not macOS"
fi
