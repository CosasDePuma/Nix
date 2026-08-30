{lib, ...}: {
  flake.nixosModules.service-prowlarr = {
    services.prowlarr = {
      enable = lib.mkDefault true;
      openFirewall = lib.mkDefault true;
    };
  };
}
