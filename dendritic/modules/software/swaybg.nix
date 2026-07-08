_: {
  flake = {
    homeManagerModules.software-swaybg = {pkgs, ...}: {
      home.packages = with pkgs; [swaybg];
    };

    nixosModules.software-swaybg = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [swaybg];
    };
  };
}
