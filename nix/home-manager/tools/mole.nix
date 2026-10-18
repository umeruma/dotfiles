# Mole (https://mole.fit): the native app is a cask, its CLI companion
# (mo clean, mo purge, ...) is mole-cleaner in nixpkgs (nixpkgs `mole` is
# an unrelated SSH tunnel tool).
{ pkgs, ... }:
{
  my.casks = [ "mole-app" ];
  home.packages = [ pkgs.mole-cleaner ];
}
