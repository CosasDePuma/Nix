{lib, ...}: {
  flake.nixosModules.service-caddy = {
    services.caddy = {
      enable = lib.mkDefault true;
      enableReload = lib.mkDefault true;
      logFormat = lib.mkDefault "level INFO";
    };
  };
}
