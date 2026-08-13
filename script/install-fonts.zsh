#!/usr/bin/env zsh
# Download fonts used by Ghostty / Neovim into ~/Library/Fonts (macOS).
# - Moralerspace Neon — https://github.com/yuru7/moralerspace (SIL OFL)
# - ChaliceIcons      — https://github.com/artlaman/chalice-icon-theme (MIT)

emulate -L zsh
set -eu
set -o pipefail
setopt EXTENDED_GLOB

source "${0:A:h}/_lib.zsh"

if [[ "$(uname -s)" != "Darwin" ]]; then
  print -r -- "(skip) install-fonts: not macOS"
  exit 0
fi

require_cmd curl
require_cmd unzip
require_cmd file

typeset -r fonts_dir="${HOME}/Library/Fonts"
mkdir -p "$fonts_dir"

install_chalice() {
  local url dest tmp
  url="https://raw.githubusercontent.com/artlaman/chalice-icon-theme/master/dist/ChaliceIcons-Regular.ttf"
  dest="${fonts_dir}/ChaliceIcons-Regular.ttf"
  tmp="$(mktemp -t ChaliceIcons-Regular.XXXXXX.ttf)"

  print -r -- "→ ChaliceIcons-Regular.ttf"
  curl -fsSL --retry 3 --retry-delay 1 -o "$tmp" "$url"
  if ! file "$tmp" | grep -qiE 'TrueType|OpenType|sfnt|font'; then
    print -r -- "error: Chalice download does not look like a font:" >&2
    file "$tmp" >&2
    rm -f "$tmp"
    return 1
  fi
  mv -f "$tmp" "$dest"
  print -r -- "  installed $dest"
}

install_moralerspace_neon() {
  # Ghostty uses font-family = Moralerspace Neon (Regular/Bold/Italic faces).
  # Pin via MORALERSPACE_TAG=vX.Y.Z; otherwise resolve latest release tag.
  local tag zip_url zip_path work f count
  tag="${MORALERSPACE_TAG:-}"
  if [[ -z "$tag" ]]; then
    tag="$(
      curl -fsSL --retry 3 "https://api.github.com/repos/yuru7/moralerspace/releases/latest" \
        | sed -n 's/.*"tag_name":[[:space:]]*"\([^"]*\)".*/\1/p' \
        | head -n 1
    )"
  fi
  if [[ -z "$tag" ]]; then
    print -r -- "error: could not resolve Moralerspace release tag (set MORALERSPACE_TAG=vX.Y.Z)" >&2
    return 1
  fi

  zip_url="https://github.com/yuru7/moralerspace/releases/download/${tag}/Moralerspace_${tag}.zip"
  zip_path="$(mktemp -t Moralerspace.XXXXXX.zip)"
  work="$(mktemp -d -t Moralerspace.XXXXXX)"

  print -r -- "→ Moralerspace Neon (${tag})"
  curl -fsSL --retry 3 --retry-delay 1 -o "$zip_path" "$zip_url"
  # Only Neon faces (matches Ghostty); smaller than installing the whole family.
  unzip -qo "$zip_path" '*/MoralerspaceNeon-*.ttf' -d "$work"
  count=0
  for f in "$work"/**/MoralerspaceNeon-*.ttf(N); do
    cp -f "$f" "${fonts_dir}/${f:t}"
    print -r -- "  installed ${fonts_dir}/${f:t}"
    count=$((count + 1))
  done
  rm -rf "$work" "$zip_path"
  if (( count == 0 )); then
    print -r -- "error: no MoralerspaceNeon-*.ttf found in ${tag} zip" >&2
    return 1
  fi
}

install_chalice
install_moralerspace_neon

print -r -- "Done. Restart Ghostty (new window) so fonts / codepoint-map reload."
