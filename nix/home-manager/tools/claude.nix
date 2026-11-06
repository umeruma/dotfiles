# Claude desktop is not in nixpkgs. claude-code from nixpkgs ships with its
# auto-updater disabled, so flake.lock pins it.
{ config, lib, pkgs, ... }:
let
  link = path: { source = config.lib.file.mkOutOfStoreSymlink "${config.my.repo}/${path}"; };
  # Claude Code only reads ~/.claude/skills; Cursor and Copilot read ~/.agents.
  skills = [
    "commit"
    "dev-crit"
    "dev-server"
    "git-wt"
    "natural-japanese"
    "orca-cli"
    "orchestration"
    "rex"
    "security-audit"
    "wtt-close"
    "wt-slots"
  ];
in
{
  my.casks = [ "claude" ];
  home.packages = [ pkgs.claude-code ];
  programs.zsh.shellAliases.c = "claude";

  home.file = {
    ".claude/CLAUDE.md" = link "home/.claude/CLAUDE.md";
  }
  // lib.genAttrs (map (s: ".claude/skills/${s}") skills) (
    n: link "home/.agents/skills/${lib.removePrefix ".claude/skills/" n}"
  );
}
