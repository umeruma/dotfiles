# Rex (https://www.superlogical.com/rex). The app is installed by hand; its
# terminals export REX_BIN_DIR, which must lead PATH for the `rex` CLI
# (https://www.superlogical.com/rex/docs/automate/cli).
{ inputs, ... }:
{
  my.claudeMcpServers.superlogical = "https://www.superlogical.com/rex/community-mcp";

  # Read by rex/init.lua and the Neovim plugin spec (nvim/lua/plugins/rex-navigator.lua)
  home.file.".local/share/rex-pane-nav".source = inputs.rex-pane-nav;

  # Loaded by rex/init.lua (rex_undo.lua, rex_open.lua). Their install.sh
  # scripts are not run: the tracked rex_*.lua files replace what they would write.
  home.file.".local/share/rex-ext/rex-undo".source = inputs.rex-undo;
  home.file.".local/share/rex-ext/rex-open".source = inputs.rex-open;

  # App settings live in defaults, not init.lua, and Rex documents no way to
  # sync them; these are its internal keys and may change between previews.
  # Fonts and the dark theme (an imported custom theme with a per-machine ID)
  # stay per machine.
  targets.darwin.defaults."com.superlogical.rex" = {
    "Workspace.activePaneBorderColor" = "accent";
    "Workspace.activePaneBorderTransition" = "fade";
    "Workspace.activityGrouping" = "priority";
    "Workspace.animationStyle" = "natural";
    "Workspace.appIcon" = "default";
    "Workspace.inactivePaneFadeMode" = "both";
    "Workspace.interfaceStyle" = "useTheme";
    "Workspace.lightThemeID" = "merino-light";
    "Workspace.paneDensity" = "comfortable";
    "Workspace.showsActivePaneBorder" = true;
    "Workspace.sidebarPosition" = "left";
    "Workspace.sidebarShowsActivity" = false;
    "Workspace.tabIconTintMode" = "off";
    "Workspace.tabStyle" = "vertical";
    "Workspace.terminalImproveTextContrast" = false;
    "Workspace.toolbarBehavior" = "alwaysShow";
    "Workspace.usesGestures" = false;
    "Workspace.usesPaneGlass" = true;
    "Workspace.usesStandardInactiveWindowPaneStyles" = true;
  };

  programs.zsh.initContent = ''
    if [ -n "$REX_BIN_DIR" ]; then
      export PATH="$REX_BIN_DIR:$PATH"
    fi

    # Exec the command and report it to the terminal for resume after a restart
    # (OSC 7577), for the same pid. Rex trusts it only if a resume.trust rule in
    # rex/init.lua names it.
    osc7577_exec() {
      [[ -n $OSC7577_TOKEN ]] || { "$@"; return; }
      (
        zmodload -F zsh/system p:sysparams
        local a body mac
        local -a argv64
        for a in "$@"; do argv64+=$(print -rn -- "$a" | base64 | tr -d '\n'); done
        body="pid=''${sysparams[pid]}:time=$(date +%s):argv=''${(j:,:)argv64}:cwd=$(print -rn -- "$PWD" | base64 | tr -d '\n')"
        # print is a builtin, so the token does not show up in the process list
        mac=$(print -rn -- "$body:$OSC7577_TOKEN" | shasum -a 256 | cut -c1-64)
        # Rex checks the pid's program when the report arrives, so send it after
        # wrappers such as nixpkgs' nvim script have exec'd the real binary
        { sleep 1; print -rn -- $'\e]7577;'"$body:mac=$mac"$'\e\\' >/dev/tty; } &!
        unset OSC7577_TOKEN
        exec "$@"
      )
    }
  '';
}
