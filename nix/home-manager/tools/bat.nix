# Also delta's syntax highlighter (cendre theme cache, `mise run theme`)
{ pkgs, ... }:
{
  home.packages = [ pkgs.bat ];

  # terminal's 16 colours (cendre); colour man pages (omarchy envs)
  home.sessionVariables = {
    BAT_THEME = "ansi";
    MANROFFOPT = "-c";
    MANPAGER = "sh -c 'col -bx | bat -l man -p'";
  };
}
