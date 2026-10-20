{lib, ...}: {
  # The dashboard itself; which services it lists, its domain and its API
  # keys are per host.
  flake.nixosModules.service-homepage = {
    services.homepage-dashboard = {
      enable = lib.mkDefault true;
      listenPort = lib.mkDefault 8082;
      settings = {
        color = lib.mkDefault "slate";
        hideVersion = lib.mkDefault true;
        useEqualHeights = lib.mkDefault true;
      };
    };
  };
}
