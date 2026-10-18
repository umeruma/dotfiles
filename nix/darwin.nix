# System-level settings. macOS defaults and the login shell stay in
# mise.macos.toml / mise.toml ([bootstrap.*]); this file only wires Nix up.
{ inputs, user, ... }:
{
  # Nix itself is installed and managed by the Determinate installer
  nix.enable = false;

  nixpkgs.hostPlatform = "aarch64-darwin";
  # Many GUI apps (Cursor, Raycast, Slack, ...) are unfree.
  # Set here because home-manager uses this pkgs (useGlobalPkgs).
  nixpkgs.config.allowUnfree = true;

  # /etc/zshrc: home-manager's .zshrc runs compinit and the prompt itself
  programs.zsh.enableCompletion = false;
  programs.zsh.promptInit = "";

  system.primaryUser = user;
  users.users.${user}.home = "/Users/${user}";

  system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;
  system.stateVersion = 6;
}
