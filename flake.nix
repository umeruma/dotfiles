{
  description = "umeruma's macOS environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Installs Homebrew itself and pins its version
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";

    # Tools not in nixpkgs. Pinned to a release tag; bump the tag to update.
    crit = {
      url = "github:tomasz-tomczyk/crit/v0.23.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # zsh plugin not in nixpkgs, sourced as-is
    k = {
      url = "github:supercrabtree/k";
      flake = false;
    };
  };

  outputs =
    inputs@{ nix-darwin, home-manager, nix-homebrew, ... }:
    let
      user = "umeruma";
    in
    {
      # Named, not keyed by hostname: switch with `darwin-rebuild switch --flake .#AME`
      darwinConfigurations.AME = nix-darwin.lib.darwinSystem {
        specialArgs = { inherit inputs user; };
        modules = [
          ./nix/darwin.nix
          nix-homebrew.darwinModules.nix-homebrew
          ./nix/homebrew.nix
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            # Move plain files in the way aside instead of failing. Foreign
            # symlinks (old mise [dotfiles] links) still fail: `mise run deploy`
            # removes those once their entries are gone.
            home-manager.backupFileExtension = "before-hm";
            home-manager.extraSpecialArgs = { inherit inputs; };
            home-manager.users.${user}.imports = [ ./nix/home-manager ];
          }
        ];
      };
    };
}
