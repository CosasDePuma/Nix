_: {
  flake = {
    darwinModules.software-node = {pkgs, ...}: {
      environment.systemPackages = [pkgs.nodejs_latest];
    };

    homeManagerModules.software-node = {pkgs, ...}: {
      home.packages = [pkgs.nodejs_latest];
    };

    nixosModules.software-node = {pkgs, ...}: {
      environment.systemPackages = [pkgs.nodejs_latest];
    };
  };
}
