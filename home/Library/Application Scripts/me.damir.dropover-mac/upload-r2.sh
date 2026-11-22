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
  d=$(mktemp -d $tmp/XXXXXX)
  cp "$f" "$d/$(openssl rand -hex 16)${ext:+.$ext}"  # 元ファイルは触らない
  # webm は Clop が mp4 に変換して大きくなるので圧縮しない
  case $ext in
    png|jpg|jpeg|gif|webp|heic|avif|tiff|mp4|mov|mkv|pdf)
      $CLOP optimise --behaviour inplace --no-progress $d/* >&2 ;;
  esac
  # Clop は拡張子を変えることがある（mov → mp4 など）ので、残ったファイルを拾う
  out=($d/*)
  $RCLONE copyto $out[1] "r2:$BUCKET/${out[1]:t}" --s3-no-check-bucket
  echo "$BASE_URL/${out[1]:t}"
done
