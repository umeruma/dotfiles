# `cd <query>` jumps by frecency; bare `cd` / `cdi` pick from history with fzy.
{ lib, pkgs, ... }:
{
  home.packages = [ pkgs.zoxide ];

  programs.zsh.initContent = ''
    eval "$(zoxide init zsh --cmd cd)"
    cdi() {
      local dir
      dir="$(zoxide query -l | ${lib.getExe pkgs.fzy} --prompt '❯ ')" || return
      __zoxide_cd "$dir"
    }
    cd() { if (( $# == 0 )); then cdi; else __zoxide_z "$@"; fi; }
  '';
}
