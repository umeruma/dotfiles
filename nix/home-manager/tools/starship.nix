# One config for zsh and PowerShell: ~/.config/starship.toml, linked by
# mise.dotfiles.toml [dotfiles]
{ pkgs, ... }:
{
  home.packages = [ pkgs.starship ];

  programs.zsh.initContent = ''
    eval "$(starship init zsh)"
  '';
}
