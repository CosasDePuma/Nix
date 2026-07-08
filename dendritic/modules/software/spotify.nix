_: {
  flake = {
    darwinModules.software-spotify = {
      homebrew.casks = ["spotify"];
    };

    homeManagerModules.software-spotify = {pkgs, ...}: {
      home.packages = with pkgs; [spotify];
    };

    nixosModules.software-spotify = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [spotify];
    };
  };
}
