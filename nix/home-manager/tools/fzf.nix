# ff: pick a file with a bat preview. eff: open the pick in $EDITOR. (omarchy aliases)
{ lib, pkgs, ... }:
{
  home.packages = [ pkgs.fzf ];

  home.sessionVariables.FZF_DEFAULT_OPTS = "--color=16 --layout=reverse --border --height=80%";

  programs.zsh.initContent = ''
    ff() { fzf --preview '${lib.getExe pkgs.bat} --style=numbers --color=always {}' "$@"; }
    eff() { local f; f="$(ff)" && [[ -n "$f" ]] && "$EDITOR" "$f"; }
  '';
}
