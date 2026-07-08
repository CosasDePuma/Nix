{
  flake = {
    homeManagerModules.software-nyxt = {pkgs, ...}: {
      home.packages = with pkgs; [nyxt];
    };

    nixosModules.software-nyxt = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [nyxt];
    };
  };
}
