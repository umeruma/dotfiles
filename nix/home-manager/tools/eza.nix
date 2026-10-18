# omarchy aliases. No icons: the font may lack Nerd Font glyphs.
{ pkgs, ... }:
{
  home.packages = [ pkgs.eza ];

  programs.zsh.shellAliases = {
    ls = "eza --group-directories-first";
    ll = "eza -lh --group-directories-first";
    la = "eza -lah --group-directories-first";
    lt = "eza --tree --level=2 --long --git";
  };
}
