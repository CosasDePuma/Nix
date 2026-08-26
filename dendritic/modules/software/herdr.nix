{inputs, ...}: {
  flake = {
    darwinModules.software-herdr = {
      homebrew.brews = ["herdr"];
    };

    homeManagerModules.software-herdr = {
      lib,
      pkgs,
      ...
    }: {
      programs.herdr = {
        enable = lib.mkDefault true;
        package = lib.mkDefault inputs.herdr.packages.${pkgs.stdenv.hostPlatform.system}.default;
        settings = {
          onboarding = lib.mkDefault false;
        };
      };
    };

    nixosModules.software-herdr = {pkgs, ...}: {
      environment.systemPackages = [
        inputs.herdr.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];
    };
  };
}
