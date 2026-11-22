# Rex (https://www.superlogical.com/rex). The app is installed by hand; its
# terminals export REX_BIN_DIR, which must lead PATH for the `rex` CLI
# (https://www.superlogical.com/rex/docs/automate/cli).
{ inputs, ... }:
{
  my.claudeMcpServers.superlogical = "https://www.superlogical.com/rex/community-mcp";
  my.configIgnore = [ "rex/rex_durable.lua" ];

  # Read by rex/init.lua and the Neovim plugin spec (nvim/lua/plugins/rex-navigator.lua)
  home.file.".local/share/rex-pane-nav".source = inputs.rex-pane-nav;

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
  '';
}
