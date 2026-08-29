{lib, ...}: {
  flake = {
    darwinModules.software-wireguard = {
      homebrew.masApps."wireguard" = lib.mkDefault 1451685025;
    };

    homeManagerModules.software-wireguard = {pkgs, ...}: {
      home.packages = with pkgs; [wireguard-tools];
    };

    nixosModules.software-wireguard = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [wireguard-tools];
    };
  };
}
