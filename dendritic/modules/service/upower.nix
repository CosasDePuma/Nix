{lib, ...}: {
  flake.nixosModules.service-upower = _: {
    services.upower.enable = lib.mkDefault true;
  };
}
