# https://github.com/k1LoW/git-wt
# wt / wr pick with fzy from the store, so removing fzy.nix keeps them working.
{ lib, pkgs, ... }:
let
  fzy = lib.getExe pkgs.fzy;
in
{
  home.packages = [ pkgs.git-wt ];

  programs.zsh.initContent = ''
    eval "$(git wt --init zsh)"

    wt() {
      local line
      line="$(git wt | tail -n +2 | ${fzy})" || return
      [[ -n "$line" ]] || return
      git wt "$(printf '%s\n' "$line" | awk '{print $(NF-1)}')"
    }

    # pick a git-wt worktree with fzy and delete it
    wr() {
      local line
      line="$(git wt | tail -n +2 | ${fzy})" || return
      [[ -n "$line" ]] || return
      local dir="$(printf '%s\n' "$line" | awk '{print $(NF-1)}')"
      git wt -d "$dir"
    }

    # ga <branch>: add a worktree and switch to it. gd [branch]: delete it from the main worktree.
    ga() { git wt "$@"; }
    gd() {
      local target="''${1:-$(git branch --show-current)}"
      cd "$(git rev-parse --path-format=absolute --git-common-dir)/.." && git wt -d "$target"
    }
  '';
}
