# config: home/.config/lazygit (via the ~/.config link); delta renders its diffs
# (theme: cendre, see bat.nix).
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    lazygit
    delta
  ];

  # osc7577_exec (rex.nix) lets Rex bring it back after a restart
  programs.zsh.shellAliases.lg = "osc7577_exec lazygit";
}
