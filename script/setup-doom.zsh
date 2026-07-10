#!/usr/bin/env zsh

emulate -L zsh
set -eu
set -o pipefail

source "${0:A:h}/_lib.zsh"

local core_dir="$HOME/.config/emacs"
local doom_repo="https://github.com/doomemacs/core"

require_cmd git

if [[ ! -d "$core_dir/.git" ]]; then
  print -r -- "==> Cloning Doom Emacs core to $core_dir"
  mkdir -p "${core_dir:h}"
  git clone --depth 1 --recurse-submodules --shallow-submodules "$doom_repo" "$core_dir"
else
  print -r -- "==> Doom Emacs core already present at $core_dir"
  if [[ ! -d "$core_dir/sources/doom+/modules" ]]; then
    print -r -- "==> Initializing Doom submodules (sources/doom+)"
    git -C "$core_dir" submodule update --init --depth 1 --recursive
  fi
fi

if ! command -v emacs >/dev/null 2>&1; then
  print -u2 -r -- "error: emacs is not installed"
  print -u2 -r -- "hint: mise run install-apps  # adds emacs via Brewfile"
  exit 127
fi

local doom="$core_dir/bin/doom"
if [[ ! -x "$doom" ]]; then
  print -u2 -r -- "error: doom script not found: $doom"
  exit 127
fi

local doom_dir="$HOME/.config/doom"

if [[ ! -f "$doom_dir/init.el" ]]; then
  print -u2 -r -- "error: $doom_dir/init.el not found"
  print -u2 -r -- "hint: mise run deploy  # symlink private config from dotfiles"
  exit 1
fi

print -r -- "==> Syncing Doom Emacs (packages + env snapshot)"
# `doom install` re-invokes `doom sync` without `--force`, which can hang on
# y-or-n-p prompts when stdin is not a TTY. Sync directly instead.
"$doom" sync --force --env </dev/null

print -r -- "==> Done. Launch with: emacs"
print -r -- "hint: doom sync   # after editing init.el or packages.el"
print -r -- "hint: doom doctor # diagnose setup issues"
