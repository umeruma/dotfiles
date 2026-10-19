# config: home/.config/lazygit (via the ~/.config link); delta renders its diffs
# (theme: cendre, see bat.nix).
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    lazygit
    delta
  ];

  programs.zsh.initContent = ''
    lg() { lazygit "''${@:-.}"; }
  '';
}
