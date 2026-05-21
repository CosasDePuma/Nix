{lib, ...}: {
  flake = {
    darwinModules.software-discord = {
      homebrew.casks = ["discord"];
    };

    homeManagerModules.software-discord = {
      programs.discord.enable = lib.mkDefault true;
    };

    nixosModules.software-discord = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [discord];
    };
  };
}
