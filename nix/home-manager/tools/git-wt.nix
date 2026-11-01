# https://github.com/k1LoW/git-wt
# wt / wr pick with fzy from the store, so removing fzy.nix keeps them working.
{ lib, pkgs, ... }:
let
  fzy = lib.getExe pkgs.fzy;
  jq = lib.getExe pkgs.jq;
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
    # wtt <branch>: add a worktree and open it in a new Rex tab
    # wtt close: confirm [Y/n], delete the current worktree (safe -d), then close this Rex tab
    wtt() {
      if [[ "$1" == close ]]; then
        local gitdir common win ans
        gitdir="$(git rev-parse --path-format=absolute --git-dir)" || return
        common="$(git rev-parse --path-format=absolute --git-common-dir)"
        [[ "$gitdir" != "$common" ]] || { echo "wtt close: not in a linked worktree" >&2; return 1; }
        read -r "ans?Delete worktree '$(git branch --show-current)' and close this tab? [Y/n] "
        [[ -z "$ans" || "$ans" == [yY]* ]] || return 1
        # capture the tab before cd/delete; this shell dies with the tab, so close goes last
        [[ -n "$REX_BLOCK" ]] && win="$(rex block inspect "$REX_BLOCK" --json | ${jq} -r .block.window_id)"
        gd || return
        [[ -n "$win" ]] && rex window close "$win"
        return
      fi
      local p; p="$(git wt --nocd "$1")" && rex window new "$1" -c "$p"
    }
    gd() {
      local target="''${1:-$(git branch --show-current)}"
      cd "$(git rev-parse --path-format=absolute --git-common-dir)/.." && git wt -d "$target"
    }
  '';
}
