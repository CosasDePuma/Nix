{
  flake = {
    homeManagerModules.software-openconnect = {pkgs, ...}: {
      home.packages = with pkgs; [openconnect];
    };

    nixosModules.software-openconnect = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [openconnect];
    };
  };
}
