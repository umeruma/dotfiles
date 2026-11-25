#!/bin/zsh
# Dropover custom script: 会社の Drive にアップし、URL を出してブラウザで開く。
# アップ先は rclone.conf の alias リモート `share:` で決まる（会社のドライブ情報を repo に置かない）。
set -euo pipefail
RCLONE=/etc/profiles/per-user/$(id -un)/bin/rclone

for f in "$@"; do
  $RCLONE copyto "$f" "share:${f:t}"
  url="https://drive.google.com/file/d/$($RCLONE lsf --format i "share:${f:t}")/view"
  echo "$url"
  open "$url"
done
