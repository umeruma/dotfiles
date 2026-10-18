# ~/.gitconfig is linked by mise.unix.toml [dotfiles]
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    git
    git-lfs
    git-sizer
    diffr
  ];
}
