# omarchy aliases. No icons: the font may lack Nerd Font glyphs.
{ pkgs, ... }:
{
  home.packages = [ pkgs.eza ];

  programs.zsh.shellAliases = {
    ls = "eza -xF --group-directories-first";
    ll = "eza -lhF --group-directories-first";
    la = "eza -lahF --group-directories-first";
    lt = "eza --tree --level=2 --long --git";
  };
}
