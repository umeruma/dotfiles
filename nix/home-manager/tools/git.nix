{ config, pkgs, ... }:
let
  link = name: { source = config.lib.file.mkOutOfStoreSymlink "${config.my.repo}/home/${name}"; };
in
{
  home.packages = with pkgs; [
    git
    git-lfs
    git-sizer
    diffr
  ];

  home.file.".gitconfig" = link ".gitconfig";
  home.file.".gitignore" = link ".gitignore"; # core.excludesfile
}
