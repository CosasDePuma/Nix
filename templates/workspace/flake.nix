{
  description = "Workspace development flake";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs =
    { self, ... }@inputs:
    let
      inherit (inputs.nixpkgs) lib;
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-linux"
        "x86_64-darwin"
      ];
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
    in
    {
      # +------------- development shells -------------+

      devShells = forEachSystem systems (
        { system, pkgs, ... }:
        {
          default = self.devShells.${system}.dev;
          dev = pkgs.mkShell {
            name = "workspace";
            buildInputs = with pkgs; [
            ];
            shellHook = "";
          };
        }
      );
    };
}
