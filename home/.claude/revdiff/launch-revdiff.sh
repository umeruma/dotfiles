#!/usr/bin/env bash
# User-layer override of the revdiff Claude Code plugin's launcher. The bundled
# launcher does not detect Rex and fails there, so inside Rex this opens revdiff
# in a floating pane over the agent's window; elsewhere it defers to the bundled one.
# Contract (references/install.md in the plugin): annotations on stdout, exit 0
# clean / 10 annotated, revdiff's stderr relayed on any other exit.
set -euo pipefail

if [ -z "${REX_BLOCK:-}" ] || ! command -v rex >/dev/null 2>&1; then
  for bundled in ${CLAUDE_SKILL_DIR:+"$CLAUDE_SKILL_DIR/scripts/launch-revdiff.sh"} \
    "$HOME"/.claude/plugins/cache/revdiff/revdiff/*/.claude-plugin/skills/revdiff/scripts/launch-revdiff.sh; do
    [ -x "$bundled" ] && exec "$bundled" "$@"
  done
  echo "error: bundled revdiff launcher not found" >&2
  exit 1
fi

rex_bin=$(command -v rex)
revdiff_bin=$(command -v revdiff) || {
  echo "error: revdiff not found in PATH" >&2
  exit 1
}

args=()
stdin_file=""
for arg in "$@"; do
  case "$arg" in
    --stdin-file=*)
      stdin_file=${arg#--stdin-file=}
      if [ ! -f "$stdin_file" ] || [ ! -r "$stdin_file" ]; then
        echo "error: --stdin-file is not a readable regular file: $stdin_file" >&2
        exit 1
      fi
      args+=(--stdin)
      ;;
    *) args+=("$arg") ;;
  esac
done

tmp=${TMPDIR:-/tmp}
out=$(mktemp "$tmp/revdiff-output-XXXXXX")
err=$(mktemp "$tmp/revdiff-err-XXXXXX")
rex_err=$(mktemp "$tmp/revdiff-rex-err-XXXXXX")
trap 'rm -f "$out" "$err" "$rex_err"' EXIT

rc=0
# shellcheck disable=SC2016
"$rex_bin" split -s "${REX_SESSION:-}" -b "$REX_BLOCK" --split=below -c "$PWD" \
  --label revdiff --wait -- \
  sh -c '"$1" api call -s "$REX_SESSION" session.float_block \
      "{\"block_id\":\"$REX_BLOCK\",\"bounds\":[0.05,0.05,0.9,0.9]}" >/dev/null 2>&1 ||
      "$1" zoom --on >/dev/null 2>&1 || true
    err=$2 in=$3; shift 3
    if [ -n "$in" ]; then exec "$@" 2>"$err" <"$in"; else exec "$@" 2>"$err"; fi' \
  sh "$rex_bin" "$err" "$stdin_file" \
  env REVDIFF_EXIT_CODE_ON_ANNOTATIONS=true "$revdiff_bin" "--output=$out" ${args[@]+"${args[@]}"} \
  >/dev/null 2>"$rex_err" || rc=$?
# Rex hands focus to a neighbouring block when the floating layer closes.
"$rex_bin" focus -s "${REX_SESSION:-}" "$REX_BLOCK" >/dev/null 2>&1 || true

if [ "$rc" -ne 0 ] && [ "$rc" -ne 10 ]; then
  if [ -s "$err" ]; then cat "$err" >&2; else cat "$rex_err" >&2; fi
fi
cat "$out"
exit "$rc"
