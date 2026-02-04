#!/usr/bin/env zsh

emulate -L zsh
set -eu
set -o pipefail

source "${0:A:h}/_lib.zsh"

local root
root=$(repo_root)
cd "$root"

find home -name ".*" -not -name ".DS_Store" -type f | sort
