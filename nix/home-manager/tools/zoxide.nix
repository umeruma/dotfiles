# `cd <query>` jumps by frecency; bare `cd` / `cdi` pick from history plus dirs under $PWD with fzy.
{ lib, pkgs, ... }:
{
  home.packages = [ pkgs.zoxide ];

  programs.zsh.initContent = ''
    eval "$(zoxide init zsh --cmd cd)"
    cdi() {
      local dir
      dir="$({ zoxide query -l; ${lib.getExe pkgs.fd} -td -d 2 -a --format '{}' . "$PWD"; } | awk '!seen[$0]++' | ${lib.getExe pkgs.fzy} --prompt '❯ ')" || return
      __zoxide_cd "$dir"
    }
    cd() { if (( $# == 0 )); then cdi; else __zoxide_z "$@"; fi; }
  '';
}
