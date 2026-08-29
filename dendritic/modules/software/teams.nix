_: {
  flake = {
    darwinModules.software-teams = {
      homebrew.casks = ["microsoft-teams"];
    };

    # teams-for-linux is the unofficial MS Teams client for Linux; the official
    # client is not packaged for NixOS.
    homeManagerModules.software-teams = {pkgs, ...}: {
      home.packages = with pkgs; [teams-for-linux];
    };

    nixosModules.software-teams = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [teams-for-linux];
    };
  };
}
