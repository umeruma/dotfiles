# Rex (https://www.superlogical.com/rex). The app is installed by hand; its
# terminals export REX_BIN_DIR, which must lead PATH for the `rex` CLI
# (https://www.superlogical.com/rex/docs/automate/cli).
{ ... }:
{
  my.claudeMcpServers.superlogical = "https://www.superlogical.com/rex/community-mcp";
  my.configIgnore = [ "rex/rex_durable.lua" ];

  programs.zsh.initContent = ''
    if [ -n "$REX_BIN_DIR" ]; then
      export PATH="$REX_BIN_DIR:$PATH"
    fi
  '';
}
