#!/usr/bin/env bash
# User-layer override of the revdiff-planning plugin's launcher. Inside Rex the
# plan opens in leaf's diff reviewer in a floating pane: the whole plan as a
# new file, or a revision against the previous one with full context. Line
# comments saved with `C` are read back from `leaf comments --json` and go to
# stdout, which the plugin's hook returns to the agent. Elsewhere it defers to
# the bundled revdiff launcher. Args: <plan> | <new> <old>, the order the
# plugin's hook passes.
set -euo pipefail

if [ -z "${REX_BLOCK:-}" ] || ! command -v rex >/dev/null 2>&1 || ! command -v leaf >/dev/null 2>&1; then
  exec "${CLAUDE_PLUGIN_ROOT:?}/scripts/launch-plan-review.sh" "$@"
fi

for f in "$@"; do
  [ -f "$f" ] || {
    echo "error: file not found: $f" >&2
    exit 1
  }
done

case $# in
  1) new=$1 old=/dev/null ;;
  2) new=$1 old=$2 ;;
  *)
    echo "usage: launch-plan-review.sh <plan-file-path> | <new-path> <old-path>" >&2
    exit 1
    ;;
esac

rex_bin=$(command -v rex)
leaf_bin=$(command -v leaf)

# A fresh path per review: leaf keys saved comments by the patch's path.
dir=$(mktemp -d "${TMPDIR:-/tmp}/plan-review-XXXXXX")
trap 'rm -rf "$dir"' EXIT
patch=$dir/plan.patch

# -U999999 keeps the whole plan on screen, not only the changed hunks.
diff -U999999 --label a/plan.md --label b/plan.md "$old" "$new" >"$patch" ||
  [ $? -eq 1 ]
[ -s "$patch" ] || diff -U999999 --label a/plan.md --label b/plan.md /dev/null "$new" >"$patch" ||
  [ $? -eq 1 ]

# shellcheck disable=SC2016
"$rex_bin" split -s "${REX_SESSION:-}" -b "$REX_BLOCK" --split=below -c "$PWD" \
  --label leaf --wait -- \
  sh -c '"$1" api call -s "$REX_SESSION" session.float_block \
      "{\"block_id\":\"$REX_BLOCK\",\"bounds\":[0.05,0.05,0.9,0.9]}" >/dev/null 2>&1 ||
      "$1" zoom --on >/dev/null 2>&1 || true
    shift; exec "$@"' \
  sh "$rex_bin" "$leaf_bin" diff "$patch" >/dev/null
# Rex hands focus to a neighbouring block when the floating layer closes.
"$rex_bin" focus -s "${REX_SESSION:-}" "$REX_BLOCK" >/dev/null 2>&1 || true

key="diff:patch:$(cd "$dir" && pwd -P)/plan.patch"
"$leaf_bin" comments --json | jq -r --arg key "$key" '
  .[] | select(.key == $key)
  | "plan.md:\(.start_line)\(if .end_line != .start_line then "-\(.end_line)" else "" end) (\(.side)): \(.body)"'
