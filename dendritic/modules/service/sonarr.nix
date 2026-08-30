{lib, ...}: {
  flake.nixosModules.service-sonarr = {
    services.sonarr = {
      enable = lib.mkDefault true;
      openFirewall = lib.mkDefault true;
    };
  };
}
