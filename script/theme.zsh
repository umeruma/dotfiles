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
  # Upstream hard (default) depth — matches Ghostty theme = cendre.
  # https://github.com/Aejkatappaja/cendre extras/macos-terminal
  open ./extras/macos-terminal/cendre.terminal
else
  print -r -- "(skip) theme: not macOS (Windows: mise run theme)"
fi
