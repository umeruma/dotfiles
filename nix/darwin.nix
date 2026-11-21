# System-level settings. macOS defaults and the login shell stay in
# mise.macos.toml / mise.toml ([bootstrap.*]); this file only wires Nix up.
{ config, inputs, user, ... }:
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

  # Touch ID for sudo (darwin-rebuild switch runs as root);
  # reattach makes it work inside tmux
  security.pam.services.sudo_local = {
    touchIdAuth = true;
    reattach = true;
  };

  # Stay reachable for Sill over Tailscale while on AC. `power.*` cannot
  # target AC only, and restartAfterPowerFailure fails on laptops.
  system.activationScripts.postActivation.text = ''
    pmset -c sleep 0
    if pmset -g cap | grep -q autorestart; then pmset -a autorestart 1; fi
  '';

  environment.systemPackages = config.home-manager.users.${user}.my.apps;

  system.primaryUser = user;
  users.users.${user}.home = "/Users/${user}";

  system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;
  system.stateVersion = 6;
}
