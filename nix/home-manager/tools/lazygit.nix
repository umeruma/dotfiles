# config.yml is linked by mise.unix.toml [dotfiles]; delta renders its diffs
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
