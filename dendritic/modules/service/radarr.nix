{lib, ...}: {
  flake.nixosModules.service-radarr = {
    services.radarr = {
      enable = lib.mkDefault true;
      openFirewall = lib.mkDefault true;
    };
  };
}
