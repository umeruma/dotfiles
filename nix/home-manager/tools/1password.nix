# Both casks: the app must live in /Applications for browser integration,
# and the CLI's app integration expects /usr/local/bin/op.
{ ... }:
{
  my.casks = [
    "1password"
    "1password-cli"
  ];
}
