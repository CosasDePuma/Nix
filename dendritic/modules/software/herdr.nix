{inputs, ...}: {
  flake = {
    darwinModules.software-herdr = {
      homebrew.brews = ["herdr"];
    };

    homeManagerModules.software-herdr = {pkgs, ...}: {
      home.packages = [
        inputs.herdr.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];
    };

    nixosModules.software-herdr = {pkgs, ...}: {
      environment.systemPackages = [
        inputs.herdr.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];
    };
  };
}
