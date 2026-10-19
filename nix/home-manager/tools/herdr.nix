# Agent multiplexer (https://herdr.dev). config: home/.config/herdr
# (via the ~/.config link); the layout functions are shared with Linux.
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
