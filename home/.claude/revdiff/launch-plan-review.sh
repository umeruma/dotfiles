#!/usr/bin/env bash
# User-layer override of the revdiff-planning plugin's launcher, for the same
# reason as launch-revdiff.sh next to it. Args: <plan> | <new> <old>, the
# order the plugin's hook passes; flags mirror the bundled launcher.
set -euo pipefail

if [ -z "${REX_BLOCK:-}" ] || ! command -v rex >/dev/null 2>&1; then
  exec "${CLAUDE_PLUGIN_ROOT:?}/scripts/launch-plan-review.sh" "$@"
fi

abs() { (cd "$(dirname "$1")" && printf '%s/%s\n' "$(pwd)" "$(basename "$1")"); }

for f in "$@"; do
  [ -f "$f" ] || {
    echo "error: file not found: $f" >&2
    exit 1
  }
done

case $# in
  1) set -- "--only=$(abs "$1")" --wrap ;;
  2) set -- "--compare-old=$(abs "$2")" "--compare-new=$(abs "$1")" --wrap --collapsed ;;
  *)
    echo "usage: launch-plan-review.sh <plan-file-path> | <new-path> <old-path>" >&2
    exit 1
    ;;
esac

exec "$(dirname "$(realpath "$0")")/launch-revdiff.sh" "$@"
