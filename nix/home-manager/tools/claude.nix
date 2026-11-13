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
    "improve"
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
  my.claudePlugins."ponytail@ponytail" = "DietrichGebert/ponytail";
  home.packages = [ pkgs.claude-code ];
  programs.zsh.shellAliases.c = "claude";

  # ~/.claude/plugins, settings.json and ~/.claude.json are Claude Code's, so
  # this only adds what is missing; removing an entry does not uninstall it.
  home.activation.claudePlugins = lib.hm.dag.entryAfter [ "writeBoundary" ] (
    ''
      export PATH="${pkgs.git}/bin:$PATH"
      claude=${pkgs.claude-code}/bin/claude
      jq=${pkgs.jq}/bin/jq
      markets=$($claude plugin marketplace list --json 2>/dev/null || echo '[]')
      plugins=$($claude plugin list --json 2>/dev/null || echo '[]')
    ''
    + lib.concatStrings (
      lib.mapAttrsToList (
        id: repo:
        let
          market = lib.escapeShellArg (lib.last (lib.splitString "@" id));
          id' = lib.escapeShellArg id;
          repo' = lib.escapeShellArg repo;
        in
        ''
          if ! $jq -e --arg n ${market} 'any(.[]; .name == $n)' <<<"$markets" >/dev/null; then
            run $claude plugin marketplace add ${repo'} || echo "claude: marketplace add ${repo} failed" >&2
            markets=$($claude plugin marketplace list --json 2>/dev/null || echo '[]')
          fi
          if ! $jq -e --arg id ${id'} 'any(.[]; .id == $id)' <<<"$plugins" >/dev/null; then
            run $claude plugin install ${id'} || echo "claude: installing ${id} failed" >&2
          fi
        ''
      ) config.my.claudePlugins
    )
    + lib.concatStrings (
      lib.mapAttrsToList (name: url: ''
        if ! $jq -e --arg n ${lib.escapeShellArg name} '.mcpServers // {} | has($n)' ~/.claude.json >/dev/null 2>&1; then
          run $claude mcp add -s user --transport http ${lib.escapeShellArg name} ${lib.escapeShellArg url} || echo "claude: mcp add ${name} failed" >&2
        fi
      '') config.my.claudeMcpServers
    )
  );

  home.file = {
    ".claude/CLAUDE.md" = link "home/.claude/CLAUDE.md";
  }
  // lib.genAttrs (map (s: ".claude/skills/${s}") skills) (
    n: link "home/.agents/skills/${lib.removePrefix ".claude/skills/" n}"
  );
}
