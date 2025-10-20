{
  description = "Áudea IaC (Infrastructure as Code) using Nix";

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
            inputs.disko.nixosModules.default
            inputs.agenix.nixosModules.default
            nixosSystem
          ];
          specialArgs = extraArgs;
        };
    in
    {

      # +------------- development shells -------------+

      devShells = forEachSystem systems (
        { system, ... }@args:
        {
          default = self.devShells.${system}.nixos;
          nixos = import ./shells/nixos.nix (args // extraArgs);
        }
      );

      # +----------------- formatter ------------------+

      formatter = forEachSystem systems (
        { system, ... }: inputs.nixpkgs.legacyPackages."${system}".nixfmt-tree
      );

      # +--------------- nixos systems ----------------+

      nixosConfigurations = {
        mobile = nixosConfiguration ./systems/x86_64-linux/redteam/03.mobile;
        proxy = nixosConfiguration ./systems/x86_64-linux/dmz/253.proxy;
        report = nixosConfiguration ./systems/x86_64-linux/redteam/01.report;
        router = nixosConfiguration ./systems/x86_64-linux/router;
        vulnerability = nixosConfiguration ./systems/x86_64-linux/redteam/02.vulnerability;
      };

      # +----------------- templates ------------------+

      templates = {
        shell = {
          path = ./templates/shell;
          description = "Shell template for development environments";
        };
      };
    };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

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
  };
}
