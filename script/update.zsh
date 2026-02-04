#!/usr/bin/env zsh

emulate -L zsh
set -eu
set -o pipefail

source "${0:A:h}/_lib.zsh"

local root
root=$(repo_root)
cd "$root"

require_cmd git

git pull origin main

git submodule init

git submodule update

git submodule foreach git pull origin main
