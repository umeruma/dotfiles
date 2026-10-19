# azooKey: Japanese input method, from GitHub Releases (not in nixpkgs; no Homebrew).
# Bump version + hash to update (a pre-release tag such as 0.1.5-beta.1 works too):
#   nix store prefetch-file https://github.com/azooKey/azooKey-Desktop/releases/download/v<version>/azooKey-release-signed.pkg
# After the first switch, add it in
# System Settings > Keyboard > Input Sources.
{ lib, pkgs, ... }:
let
  version = "0.1.4";
  azookey = pkgs.stdenvNoCC.mkDerivation {
    pname = "azookey";
    inherit version;
    src = pkgs.fetchurl {
      url = "https://github.com/azooKey/azooKey-Desktop/releases/download/v${version}/azooKey-release-signed.pkg";
      hash = "sha256-04kxXJKMKNpzLE6yrejtDBnIlv3wb4NTrGF9ldzys5w=";
    };
    nativeBuildInputs = [ pkgs.xar pkgs.cpio ];
    # The pkg only drops azooKeyMac.app into Input Methods; no install scripts
    unpackPhase = ''
      xar -xf $src
      gzip -dc azooKey-tmp.pkg/Payload | cpio -id
    '';
    installPhase = "cp -R azooKeyMac.app $out";
    dontFixup = true; # keep the code signature intact
  };
in
{
  # Copied, not linked, like the fonts; the marker skips the copy when unchanged
  home.activation.azookey = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    dir="$HOME/Library/Input Methods"
    if [[ "$(cat "$dir/.azookey-source" 2>/dev/null)" != ${azookey} ]]; then
      run /usr/bin/pkill -x azooKeyMac || true
      run mkdir -p "$dir"
      run rm -rf "$dir/azooKeyMac.app"
      run cp -R ${azookey} "$dir/azooKeyMac.app"
      run chmod -R u+w "$dir/azooKeyMac.app"
      run sh -c "echo ${azookey} > '$dir/.azookey-source'"
    fi
  '';
}
