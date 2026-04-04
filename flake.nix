{
  description = "My own IaC (Infrastructure as Code) using Nix";

  outputs =
    { self, ... }@inputs:
    let
      inherit (inputs.nixpkgs) lib;
      systems = [
        "aarch64-darwin"
        "x86_64-linux"
      ];
      extraArgs = {
        inherit inputs lib;
        homeModules = [
          inputs.catppuccin.homeModules.default
        ];
        stateVersion = "25.05";
      };
      forEachSystem =
        supportedSystems: fn:
        lib.genAttrs supportedSystems (
          system:
          fn {
            inherit system;
            pkgs = import inputs.nixpkgs {
              inherit system;
              config.allowUnfree = true;
            };
          }
        );
      nixosConfiguration =
        nixosSystem:
        lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            inputs.agenix.nixosModules.default
            inputs.disko.nixosModules.default
            inputs.home-manager.nixosModules.default
            nixosSystem
          ];
          specialArgs = extraArgs;
        };
      darwinConfiguration =
        darwinSystem:
        inputs.nix-darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          modules = [ darwinSystem ];
          specialArgs = extraArgs // {
            user = "pumita";
          };
        };
    in
    {
      # +--------------- darwin systems ---------------+

      darwinConfigurations = {
        airbender = darwinConfiguration ./systems/aarch64-darwin/airbender;
      };

      # +------------- development shells -------------+

      devShells = forEachSystem systems (
        { system, ... }@args:
        {
          default = self.devShells.${system}.nixos;
          hacking = import ./shells/hacking.nix (args // extraArgs);
          hacking-infra = import ./shells/hacking-infra.nix (args // extraArgs);
          nixos = import ./shells/nixos.nix (args // extraArgs);
        }
      );

      # +----------------- formatter ------------------+

      formatter = forEachSystem systems (
        { system, ... }: inputs.nixpkgs.legacyPackages."${system}".nixfmt-tree
      );

      # +--------------- nixos systems ----------------+

      nixosConfigurations = {
        # --- | Desktop
        wonderland = nixosConfiguration ./systems/x86_64-linux/desktop/wonderland;
        # --- | Homelab
        automation = nixosConfiguration ./systems/x86_64-linux/homelab/automation;
        media = nixosConfiguration ./systems/x86_64-linux/homelab/media;
        proxy = nixosConfiguration ./systems/x86_64-linux/homelab/proxy;
        router = nixosConfiguration ./systems/x86_64-linux/homelab/router;
      };

      # +----------------- templates ------------------+

      templates = {
        workspace = {
          path = ./templates/workspace;
          description = "Workspace template";
        };
      };
    };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    # secret management
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # disk partitioning to be used with `nixos-anywhere`
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # user-defined configurations
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # nix darwin support
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # --- themes
    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
