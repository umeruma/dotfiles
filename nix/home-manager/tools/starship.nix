# One config for zsh and PowerShell: home/.config/starship.toml (~/.config
# links to home/.config, see dotfiles.nix)
{ pkgs, ... }:
{
  home.packages = [ pkgs.starship ];

  programs.zsh.initContent = ''
    eval "$(starship init zsh)"
  '';
}
