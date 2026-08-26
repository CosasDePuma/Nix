{
  inputs,
  lib,
  ...
}: {
  flake = {
    darwinModules.software-herdr = {
      homebrew.brews = ["herdr"];
    };

    homeManagerModules.software-herdr = {pkgs, ...}: {
      home.packages = [
        inputs.herdr.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];

      xdg.configFile."herdr/config.toml".text = lib.mkDefault ''
        onboarding = false
      '';
    };

    nixosModules.software-herdr = {pkgs, ...}: {
      environment.systemPackages = [
        inputs.herdr.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];
    };
  };
}
