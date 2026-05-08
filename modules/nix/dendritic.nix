{ inputs, lib, ... }:
{
  imports = [
    inputs.flake-parts.flakeModules.modules
    inputs.flake-parts.flakeModules.nixosConfigurations
  ];

  options = {
    flake.lib = lib.mkOption {
      type = lib.types.attrsOf lib.types.unspecified;
      default = { };
    };

    flake.darwinConfigurations = lib.mkOption {
      type = lib.types.lazyAttrsOf lib.types.raw;
      default = { };
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
            inputs.self.modules.nixos.${name}
            { nixpkgs.hostPlatform = lib.mkDefault system; }
          ];
        };
      };

      lib.mkDarwin = system: name: {
        ${name} = inputs.nix-darwin.lib.darwinSystem {
          modules = [
            inputs.self.modules.darwin.${name}
            { nixpkgs.hostPlatform = lib.mkDefault system; }
          ];
        };
      };

      templates.workspace = {
        path = ../../templates/workspace;
        description = "Workspace template";
      };
    };

    perSystem =
      { pkgs, system, ... }:
      {
        formatter = pkgs.nixfmt-tree;

        devShells = {
          default = import ../../shells/nixos.nix { inherit pkgs system inputs; };
          nixos = import ../../shells/nixos.nix { inherit pkgs system inputs; };
        };
      };
  };
}
