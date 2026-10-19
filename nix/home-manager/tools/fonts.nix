# Fonts for Ghostty and Neovim. home-manager copies them into
# ~/Library/Fonts/HomeManager.
# - Moralerspace (SIL OFL): the whole family; Ghostty uses Neon.
# - ChaliceIcons (MIT): not in nixpkgs; pinned to a commit, bump it to update.
{ pkgs, ... }:
let
  chalice-icons = pkgs.runCommand "chalice-icons" {
    src = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/artlaman/chalice-icon-theme/b18663d1eacbeea7e31b02aa0016f00f25c59a09/dist/ChaliceIcons-Regular.ttf";
      hash = "sha256-01a/RCm5CsI4rN6Sv/NP7GfEn+S9I85n7R0x19xouIg=";
    };
  } "install -Dm444 $src $out/share/fonts/ChaliceIcons-Regular.ttf";
in
{
  home.packages = [
    pkgs.moralerspace
    chalice-icons
  ];
}
