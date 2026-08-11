{lib, ...}: {
  flake = {
    darwinModules.software-bitwarden = {
      homebrew = {
        brews = ["bitwarden-cli"];
        masApps."bitwarden" = lib.mkDefault 1137397744;
      };
    };

    homeManagerModules.software-bitwarden = {pkgs, ...}: {
      home.packages = with pkgs; [bitwarden-desktop bitwarden-cli];
    };

    nixosModules.software-bitwarden = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [bitwarden-desktop bitwarden-cli];
    };
  };
}
