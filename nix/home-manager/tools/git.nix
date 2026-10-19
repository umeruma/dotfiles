# ~/.gitconfig is linked by dotfiles.nix
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    git
    git-lfs
    git-sizer
    diffr
  ];
}
