{
  flake = {
    homeManagerModules.software-teams = {pkgs, ...}: {
      home.packages = with pkgs; [teams-for-linux];
    };

    nixosModules.software-teams = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [teams-for-linux];
    };
  };
}
