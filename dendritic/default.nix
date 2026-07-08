{
  inputs,
  lib,
  ...
}: {
  imports = [
    inputs.flake-parts.flakeModules.nixosConfigurations
    inputs.treefmt-nix.flakeModule
  ];

  options = {
    flake.darwinModules = lib.mkOption {
      type = lib.types.lazyAttrsOf lib.types.unspecified;
      default = {};
    };

    flake.homeManagerModules = lib.mkOption {
      type = lib.types.lazyAttrsOf lib.types.unspecified;
      default = {};
    };

    flake.lib = lib.mkOption {
      type = lib.types.attrsOf lib.types.unspecified;
      default = {};
    };

    flake.darwinConfigurations = lib.mkOption {
      type = lib.types.lazyAttrsOf lib.types.raw;
      default = {};
    };
  };

  config = {
    systems = [
      "aarch64-darwin"
      "aarch64-linux"
      "x86_64-darwin"
      "x86_64-linux"
    ];

    flake = {
      lib.mkNixos = system: name: {
        ${name} = inputs.nixpkgs.lib.nixosSystem {
          modules = [
            inputs.disko.nixosModules.default
            inputs.agenix.nixosModules.default
            inputs.self.nixosModules.${name}
            {nixpkgs.hostPlatform = lib.mkDefault system;}
          ];
        };
      };

      lib.mkDarwin = system: name: {
        ${name} = inputs.nix-darwin.lib.darwinSystem {
          modules = [
            inputs.self.darwinModules.${name}
            {nixpkgs.hostPlatform = lib.mkDefault system;}
          ];
        };
      };

      templates.workspace = {
        path = ../templates/workspace;
        description = "Workspace template";
      };
    };

    perSystem = {
      config,
      pkgs,
      system,
      ...
    }: {
      treefmt = {
        projectRootFile = "flake.nix";
        programs = {
          alejandra.enable = true;
          deadnix.enable = true;
          keep-sorted.enable = true;
          statix.enable = true;
        };
      };

      formatter = config.treefmt.build.wrapper;

      devShells = {
        default = import ../shells/nixos.nix {inherit pkgs system inputs;};
        nixos = import ../shells/nixos.nix {inherit pkgs system inputs;};
      };
    };
  };
}
