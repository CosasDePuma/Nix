_: {
  flake = {
    darwinModules.software-discord = {
      homebrew.casks = ["discord"];
    };

    homeManagerModules.software-discord = {pkgs, ...}: {
      home.packages = with pkgs; [discord];
    };

    nixosModules.software-discord = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [discord];
    };
  };
}
