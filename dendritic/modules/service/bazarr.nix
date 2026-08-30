{lib, ...}: {
  flake.nixosModules.service-bazarr = {
    services.bazarr = {
      enable = lib.mkDefault true;
      openFirewall = lib.mkDefault true;
    };
  };
}
