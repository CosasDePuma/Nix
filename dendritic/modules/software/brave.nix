_: {
  flake = {
    homeManagerModules.software-brave = {pkgs, ...}: {
      home.packages = [pkgs.brave-origin];
    };

    nixosModules.software-brave = {pkgs, ...}: {
      environment.systemPackages = [pkgs.brave-origin];
    };
  };
}
