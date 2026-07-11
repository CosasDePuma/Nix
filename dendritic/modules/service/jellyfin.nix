{lib, ...}: {
  flake.nixosModules.service-jellyfin = {
    services.jellyfin.enable = lib.mkDefault true;
  };
}
