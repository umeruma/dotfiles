#!/usr/bin/env bash
# Generate Conventional Commit subject + description from STAGED changes only.
# Quiet while running — lazygit shows `loadingText` in the bottom status bar.
# The message is written to lazygit's own preserved-message file
# (.git/LAZYGIT_PENDING_COMMIT, the one it restores after Esc), so `c` opens
# the commit panel already filled in. When lazygit runs inside a Neovim
# terminal (LazyVim integration), `c` is injected through nvim's RPC socket
# ($NVIM) — no macOS permissions needed. Otherwise we exit 1 with a hint so
# lazygit shows it as a popup and you press `c` yourself.
set -euo pipefail

fail() {
  printf '%s\n' "$*" >&2
  exit 1
}

if ! command -v cursor-agent >/dev/null 2>&1 && ! command -v agent >/dev/null 2>&1; then
  fail "cursor-agent not found (brew install --cask cursor-cli)"
fi

# TODO: make the generator swappable via an env var (e.g. LAZYGIT_AI_CMD="claude -p") instead of hardcoding cursor-agent.
AGENT=(cursor-agent)
command -v cursor-agent >/dev/null 2>&1 || AGENT=(agent)

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  fail "not a git repository"
fi

if git diff --cached --quiet; then
  fail "no staged changes (stage files first)"
fi

STAT=$(git diff --cached --stat)
DIFF=$(git diff --cached)
if [ "${#DIFF}" -gt 24000 ]; then
  DIFF=$(printf '%s' "$DIFF" | head -c 24000)
  DIFF+=$'\n\n[staged diff truncated]'
fi

PROMPT=$(
  cat <<EOF
Write a git commit message for the STAGED changes only.
Ignore anything not in this staged diff.

Output format (exact):
Line 1: Conventional Commits subject only
  type(optional-scope): description
  English, imperative ("add" not "added"), max 72 characters
  Types: feat, fix, docs, style, refactor, perf, test, chore, ci
Then a blank line.
Then a short description body (1-3 sentences) explaining what and why.
No markdown, no bullets, no code fences, no surrounding quotes.

staged --stat:
$STAT

staged diff:
$DIFF
EOF
)

errfile=$(mktemp)
trap 'rm -f "$errfile"' EXIT

set +e
RAW=$("${AGENT[@]}" -p --mode ask --output-format text --trust \
  --model composer-2.5-fast -- "$PROMPT" 2>"$errfile")
agent_status=$?
set -e

if [ "$agent_status" -ne 0 ]; then
  err=$(cat "$errfile" 2>/dev/null || true)
  fail "cursor-agent failed (try: cursor-agent login, or export CURSOR_API_KEY)${err:+: $err}"
fi

# Drop code fences, leading blank lines, and surrounding whitespace per line.
RAW=$(printf '%s\n' "$RAW" | sed -e '/^```/d' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | sed -e '/./,$!d')

subject=$(printf '%s\n' "$RAW" | head -n 1 | sed -e 's/^["`]*//' -e 's/["`]*$//')
# Body = everything after the subject, minus leading blank lines (tolerates a missing blank line).
body=$(printf '%s\n' "$RAW" | tail -n +2 | sed -e '/./,$!d')

[ -n "$subject" ] || fail "empty commit subject from cursor-agent"

# lazygit preserved-message format: summary + "\n" + description (no blank line).
nl=$'\n'
printf '%s' "$subject${body:+$nl}$body" >| "$(git rev-parse --git-dir)/LAZYGIT_PENDING_COMMIT"

if [ -n "${NVIM:-}" ]; then
  # Fire after this script has returned and lazygit is back in the files view.
  (
    sleep 0.3
    nvim --server "$NVIM" --remote-send 'c'
  ) >/dev/null 2>&1 &
  disown 2>/dev/null || true
  exit 0
fi

fail "Commit message written. Press c to open the commit panel.${nl}${nl}$subject${body:+$nl$nl}$body"
