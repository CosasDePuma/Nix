{lib, ...}: {
  flake.modules = {
    darwin.software-discord = {
      homebrew.casks = ["discord"];
    };

    homeManager.software-discord = {
      programs.discord.enable = lib.mkDefault true;
    };

    nixos.software-discord = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [
        discord
      ];
    };
  };
}
