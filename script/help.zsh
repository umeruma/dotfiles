#!/usr/bin/env zsh

emulate -L zsh
set -eu
set -o pipefail

# Lists available mise tasks.
if command -v mise >/dev/null 2>&1; then
  mise tasks
else
  print -u2 -r -- "error: mise is not installed"
  print -u2 -r -- "hint: https://mise.jdx.dev/"
  exit 127
fi
