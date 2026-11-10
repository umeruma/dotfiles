#!/usr/bin/env zsh

emulate -L zsh
set -eu
set -o pipefail

source "${0:A:h}/_lib.zsh"

cd "$(repo_root)"

local -i failed=0
fail() {
  print -u2 -r -- "FAIL: $*"
  failed=1
}

local f s
for f in mise.linux.toml mise.windows.toml; do
  for s in ${(f)"$(grep -o 'source = "[^"]*"' "$f" | sed -e 's/^source = "//' -e 's/"$//')"}; do
    [[ -e $s ]] || fail "$f: source not found: $s"
  done
done

# Rex does not exist on Windows, so its skills are not linked there.
local -a skills windows_skip=(rex wtt-close)
skills=(${(f)"$(sed -n '/^  skills = \[/,/^  \];/p' nix/home-manager/tools/claude.nix | grep -o '"[^"]*"' | tr -d '"')"})
(( ${#skills} )) || fail "nix/home-manager/tools/claude.nix: skills list not found"
for s in $skills; do
  [[ -d home/.agents/skills/$s ]] || fail "claude.nix: skill dir not found: home/.agents/skills/$s"
  grep -qF "\"~/.claude/skills/$s\"" mise.linux.toml || fail "mise.linux.toml: missing entry ~/.claude/skills/$s"
  (( ${windows_skip[(Ie)$s]} )) && continue
  grep -qF "\"~/.claude/skills/$s\"" mise.windows.toml || fail "mise.windows.toml: missing entry ~/.claude/skills/$s"
done

for f in script/unix/*.zsh script/linux/*.zsh home/.zshenv home/.zprofile home/.zshrc; do
  zsh -n "$f" || fail "zsh syntax: $f"
done

if command -v shellcheck >/dev/null 2>&1; then
  shellcheck -S warning install script/macos/init.sh .githooks/pre-commit home/.config/lazygit/generate-commit-msg.sh || fail "shellcheck"
else
  print -r -- "(skip) shellcheck not installed"
fi

if [[ "$(uname -s)" == Darwin && -x /nix/var/nix/profiles/default/bin/nix ]]; then
  /nix/var/nix/profiles/default/bin/nix flake check --no-build || fail "nix flake check"
else
  print -r -- "(skip) nix flake check: macOS with Nix only"
fi

if (( failed )); then
  print -u2 -r -- "check: FAILED"
  exit 1
fi
print -r -- "check: OK"
