#!/usr/bin/env zsh

emulate -L zsh
set -eu
set -o pipefail

source "${0:A:h}/_lib.zsh"

local root
root=$(repo_root)

# Remove every symlink under the scan roots whose target points into the
# repo's home/ tree — including dangling links. Real files and dirs
# (app runtime state) are never touched.

print -r -- "Removing symlinks pointing into $root/home ..."

local -a scan_roots=(
  "$HOME/.zshenv" "$HOME/.zprofile" "$HOME/.zshrc" "$HOME/.gitconfig"
  "$HOME/.hammerspoon" "$HOME/.config"
  "$HOME/.claude" "$HOME/.cursor" "$HOME/.copilot" "$HOME/.agents"
)

local removed=0
local p link target
for p in "${scan_roots[@]}"; do
  [[ -e $p || -L $p ]] || continue
  while IFS= read -r link; do
    target=$(readlink "$link")
    [[ $target = /* ]] || target="${link:h}/$target"
    target=${target:a}
    if [[ $target == "$root/home" || $target == "$root/home/"* ]]; then
      print -r -- "unlink: $link -> $target"
      rm "$link"
      removed=$(( removed + 1 ))
    fi
  done < <(find "$p" -maxdepth 6 -type l 2>/dev/null)
done

# Prune dirs the sweep may have emptied (deepest first) so that
# whole-dir [dotfiles] entries can be applied in their place.
local -a prune_dirs=(
  "$HOME/.config/ghostty/shaders"
  "$HOME/.config/doom"
  "$HOME/.config/ghostty"
  "$HOME/.config/sheldon"
  "$HOME/.config/micro/plug/editorconfig/help"
  "$HOME/.config/micro/plug/editorconfig"
  "$HOME/.config/karabiner/assets/complex_modifications"
  "$HOME/.claude/skills/commit"
  "$HOME/.claude/skills/dev-server"
  "$HOME/.claude/skills/git-wt"
  "$HOME/.cursor/skills/commit"
  "$HOME/.cursor/skills/dev-server"
  "$HOME/.cursor/skills/git-wt"
  "$HOME/.copilot/skills/commit"
  "$HOME/.copilot/skills/dev-server"
  "$HOME/.copilot/skills/git-wt"
)

local d
for d in "${prune_dirs[@]}"; do
  if [[ -d $d && ! -L $d ]] && rmdir "$d" 2>/dev/null; then
    print -r -- "rmdir:  $d"
  fi
done

print -r -- "Done ($removed symlink(s) removed)."
