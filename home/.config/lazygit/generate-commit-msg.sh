#!/usr/bin/env bash
# Generate Conventional Commit subject + description from STAGED changes only.
# Quiet while running — lazygit shows `loadingText` in the bottom status bar.
# The message is written to lazygit's own preserved-message file
# (.git/LAZYGIT_PENDING_COMMIT, the one it restores after Esc), so `c` opens
# the commit panel already filled in. When lazygit runs inside a Neovim
# terminal (LazyVim integration), `c` is injected through nvim's RPC socket
# ($NVIM) — no macOS permissions needed. In a Rex pane it goes through
# `rex send` ($REX_BLOCK) instead. Otherwise we exit 1 with a hint so
# lazygit shows it as a popup and you press `c` yourself.
set -euo pipefail

fail() {
  printf '%s\n' "$*" >&2
  exit 1
}

# Generator: the prompt is appended as `-- "$PROMPT"`. Override with LAZYGIT_AI_CMD, e.g.
#   LAZYGIT_AI_CMD='cursor-agent -p --mode ask --output-format text --trust --model composer-2.5-fast'
# The default skips settings, MCP and session files: ~3s instead of cursor-agent's ~10s.
if [ -n "${LAZYGIT_AI_CMD:-}" ]; then
  read -r -a AGENT <<<"$LAZYGIT_AI_CMD"
else
  # Rules come from the commit template (~/.gitmessage), with its "# " stripped.
  template=$(git config --path commit.template 2>/dev/null || true)
  [ -r "$template" ] || fail "commit.template not readable (link home/.gitmessage)"
  SYSTEM="You write git commit messages and output nothing else. Follow these rules exactly:
$(sed -e 's/^# \{0,1\}//' "$template")"
  AGENT=(claude -p --model haiku --tools "" --strict-mcp-config --setting-sources "" --no-session-persistence
    --system-prompt "$SYSTEM")
fi
command -v "${AGENT[0]}" >/dev/null 2>&1 || fail "${AGENT[0]} not found (set LAZYGIT_AI_CMD to another generator)"

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  fail "not a git repository"
fi

if git diff --cached --quiet; then
  fail "no staged changes (stage files first)"
fi

STAT=$(git diff --cached --stat)
DIFF=$(git diff --cached)
if [ "${#DIFF}" -gt 24000 ]; then
  DIFF=${DIFF:0:24000} # not `| head -c`: SIGPIPE + pipefail exits 141
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
RAW=$("${AGENT[@]}" -- "$PROMPT" 2>"$errfile")
agent_status=$?
set -e

if [ "$agent_status" -ne 0 ]; then
  err=$(cat "$errfile" 2>/dev/null || true)
  fail "${AGENT[0]} failed${err:+: $err}"
fi

# Drop code fences, blank lines, and surrounding whitespace / quotes per line.
# (bash 3.2 on macOS has no `mapfile`, so read the lines in a loop.)
lines=()
while IFS= read -r line; do
  lines+=("$line")
done < <(
  printf '%s\n' "$RAW" |
    sed -e '/^```/d' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' \
      -e 's/^["`]*//' -e 's/["`]*$//' |
    sed -e '/^$/d'
)

# Take the first Conventional Commits line even if the model put prose first;
# without one, fail rather than write a non-conforming message.
conv='^(feat|fix|docs|style|refactor|perf|test|chore|ci)(\([^)]*\))?(!)?:[[:space:]]+[^[:space:]]'
nl=$'\n'
subject_idx=-1
for i in "${!lines[@]}"; do
  if [[ "${lines[$i]}" =~ $conv ]]; then
    subject_idx=$i
    break
  fi
done
(( subject_idx >= 0 )) || fail "no Conventional Commits subject in ${AGENT[0]} output:${nl}${RAW}"

subject="${lines[$subject_idx]:-}"
if (( subject_idx + 1 < ${#lines[@]} )); then
  body=$(printf '%s\n' "${lines[@]:$((subject_idx + 1))}")
  body=${body%%$'\n'}
else
  body=
fi

[ -n "$subject" ] || fail "empty commit subject from ${AGENT[0]}"

# lazygit preserved-message format: summary + "\n" + description (no blank line).
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

# Rex terminal (https://www.superlogical.com/rex): type `c` into this pane.
rex=$(command -v rex || echo "${REX_BIN_DIR:-}/rex")
if [ -n "${REX_BLOCK:-}" ] && [ -x "$rex" ]; then
  (
    sleep 0.3
    "$rex" send -b "$REX_BLOCK" c
  ) >/dev/null 2>&1 &
  disown 2>/dev/null || true
  exit 0
fi

fail "Commit message written. Press c to open the commit panel.${nl}${nl}$subject${body:+$nl$nl}$body"
