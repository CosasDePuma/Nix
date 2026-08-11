{lib, ...}: {
  flake = {
    darwinModules.software-steam = {
      homebrew = {
        casks = ["steam"];
        masApps."steamlink" = lib.mkDefault 1246969117;
      };
    };

    nixosModules.software-steam = {
      programs.steam = {
        enable = lib.mkDefault true;
        gamescopeSession.enable = lib.mkDefault true;
        remotePlay.openFirewall = lib.mkDefault true;
        localNetworkGameTransfers.openFirewall = lib.mkDefault true;
      };
    };
  };
}
