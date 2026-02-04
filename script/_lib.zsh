#!/usr/bin/env zsh

emulate -L zsh
set -eu
set -o pipefail

# Absolute path to this file's directory (stable even when sourced).
DOTFILES_SCRIPT_DIR=${${(%):-%x}:A:h}

# Returns repository root (dotfiles root).
repo_root() {
  local root
  root=${DOTFILES_SCRIPT_DIR:h}
  print -r -- "$root"
}

require_cmd() {
  local cmd=${1:?command required}
  if ! command -v "$cmd" >/dev/null 2>&1; then
    print -u2 -r -- "error: required command not found: $cmd"
    return 127
  fi
}
