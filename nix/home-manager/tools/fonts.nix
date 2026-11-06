# Fonts for Ghostty. home-manager copies them into ~/Library/Fonts/HomeManager.
# Moralerspace (SIL OFL): the whole family; Ghostty uses Neon.
{ pkgs, ... }:
{
  home.packages = [ pkgs.moralerspace ];
}
