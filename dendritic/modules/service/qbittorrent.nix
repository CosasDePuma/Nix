{lib, ...}: {
  flake.nixosModules.service-qbittorrent = {
    services.qbittorrent = {
      enable = lib.mkDefault true;
      openFirewall = lib.mkDefault true;
      webuiPort = lib.mkDefault 8080;
      torrentingPort = lib.mkDefault 61640;
    };
  };
}
