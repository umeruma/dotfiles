# Claude desktop is not in nixpkgs. claude-code from nixpkgs ships with its
# auto-updater disabled, so flake.lock pins it.
{ pkgs, ... }:
{
  my.casks = [ "claude" ];
  home.packages = [ pkgs.claude-code ];
}
