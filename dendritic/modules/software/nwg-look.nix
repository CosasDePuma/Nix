_: {
  flake = {
    homeManagerModules.software-nwg-look = {pkgs, ...}: {
      home.packages = with pkgs; [nwg-look];
    };

    nixosModules.software-nwg-look = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [nwg-look];
    };
  };
}
