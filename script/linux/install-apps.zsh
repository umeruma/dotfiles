#!/usr/bin/env zsh

emulate -L zsh
set -eu
set -o pipefail

# Linux only (mise.linux.toml). macOS installs apps via `mise run switch`.
source "${0:A:h:h}/unix/_lib.zsh"

cd "$(repo_root)"

require_cmd brew
brew bundle --file=./script/linux/Brewfile

if command -v apt-get >/dev/null 2>&1; then
  sudo apt-get install hugo
else
  print -u2 -r -- "warn: apt-get not found; skipping 'sudo apt-get install hugo'"
fi
