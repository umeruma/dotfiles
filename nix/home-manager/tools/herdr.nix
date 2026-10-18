# Agent multiplexer (https://herdr.dev). config.toml is linked by
# mise.unix.toml [dotfiles]; the layout functions are shared with Linux.
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    herdr
    jq # herdr.zsh parses herdr's JSON output
  ];

  programs.zsh.initContent = ''
    hr() { herdr "$@"; }
    # hdl / hdlm / hsl: dev layouts (editor + agent + terminal), ported from omarchy
    ${builtins.readFile ../../../home/.config/zsh/herdr.zsh}
  '';
}
