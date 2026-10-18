#!/bin/zsh
# Dropover custom script: Clop で圧縮 → ランダム名 → R2 にアップし、URL を1行ずつ出す。
# 認証情報は 1Password が正。`upload-r2.sh --sync` でキーチェーンにキャッシュする
# （D&D ごとの Touch ID を避けるため）。キーを替えたら --sync を再実行。
set -euo pipefail
OP_ITEM="op://Private/Cloudflare R2 Dropover"
KC=dropover-r2
CLOP=/Applications/Clop.app/Contents/SharedSupport/ClopCLI
RCLONE=/etc/profiles/per-user/$(id -un)/bin/rclone
OP=/opt/homebrew/bin/op

kc() { security find-generic-password -s $KC -a $1 -w; }

if [[ ${1:-} == --sync ]]; then
  for k in access_key_id secret_access_key account_id bucket base_url; do
    security add-generic-password -U -s $KC -a $k -w "$($OP read "$OP_ITEM/$k")"
  done
  echo "synced to keychain ($KC)"
  exit
fi

BUCKET=$(kc bucket)
BASE_URL=${$(kc base_url)%/}
# rclone のリモートは env だけで定義し、rclone.conf にキーを置かない
export RCLONE_CONFIG_R2_TYPE=s3 RCLONE_CONFIG_R2_PROVIDER=Cloudflare
export RCLONE_CONFIG_R2_ACCESS_KEY_ID=$(kc access_key_id)
export RCLONE_CONFIG_R2_SECRET_ACCESS_KEY=$(kc secret_access_key)
export RCLONE_CONFIG_R2_ENDPOINT="https://$(kc account_id).r2.cloudflarestorage.com"

tmp=$(mktemp -d)
trap 'rm -rf $tmp' EXIT
for f in "$@"; do
  ext=${${f:e}:l}
  name=$(openssl rand -hex 16)${ext:+.$ext}
  cp "$f" "$tmp/$name"  # 元ファイルは触らない
  case $ext in
    png|jpg|jpeg|gif|webp|heic|avif|tiff|mp4|mov|webm|mkv|pdf)
      $CLOP optimise --behaviour inplace --no-progress "$tmp/$name" >&2 ;;
  esac
  $RCLONE copyto "$tmp/$name" "r2:$BUCKET/$name" --s3-no-check-bucket
  echo "$BASE_URL/$name"
done
