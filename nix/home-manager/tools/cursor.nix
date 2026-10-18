{ pkgs, ... }:
{
  home.packages = with pkgs; [
    code-cursor
    cursor-cli
  ];

  programs.zsh.initContent = ''
    # Editor Window; skip Agents/Glass on launch
    alias cursor='cursor --classic'
    cua() { cursor-agent "$@"; }
  '';
}
