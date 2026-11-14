# Terminal reader for PDFs, markdown and articles, and a diff reviewer that
# sends line comments to the agent pane in Rex
# (https://github.com/DeepanshuMishraa/leaf). Not in nixpkgs; built from
# leaf's own flake (see flake.nix inputs).
# `leaf rex install` is not run: it writes this binary's store path into
# home/.config/rex/init.lua.
{ inputs, pkgs, ... }:
{
  home.packages = [ inputs.leaf.packages.${pkgs.stdenv.hostPlatform.system}.default ];

  # Inside Rex, the reader, diff and PR views open in a floating pane over
  # this window (zoomed when floating fails); subcommands that only print or
  # set something run here.
  programs.zsh.initContent = ''
    leaf() {
      case "$1" in
        comments | ask | rex | plugin | voice | voices | agents | ui | version | upgrade | -h | --help | -V | --version)
          command leaf "$@"
          return
          ;;
      esac
      if [[ -z "$REX_BLOCK" || ! -t 1 ]] || (( ! $+commands[rex] )); then
        command leaf "$@"
        return
      fi
      rex split -s "$REX_SESSION" -b "$REX_BLOCK" --split=below -c "$PWD" \
        --label leaf --wait -- \
        sh -c '"$1" api call -s "$REX_SESSION" session.float_block \
            "{\"block_id\":\"$REX_BLOCK\",\"bounds\":[0.05,0.05,0.9,0.9]}" >/dev/null 2>&1 ||
            "$1" zoom --on >/dev/null 2>&1 || true
          shift; exec "$@"' \
        sh "$commands[rex]" "$commands[leaf]" "$@" >/dev/null
      rex focus -s "$REX_SESSION" "$REX_BLOCK" >/dev/null 2>&1
    }
  '';
}
