_: {
  flake = {
    darwinModules.software-bun = {pkgs, ...}: {
      environment.systemPackages = [pkgs.bun];
    };

    homeManagerModules.software-bun = {pkgs, ...}: {
      home.packages = [pkgs.bun];
    };

    nixosModules.software-bun = {pkgs, ...}: {
      environment.systemPackages = [pkgs.bun];
    };
  };
}
