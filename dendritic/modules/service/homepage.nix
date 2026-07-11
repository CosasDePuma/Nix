{lib, ...}: {
  flake.nixosModules.service-homepage = {config, ...}: let
    homepageConfig = builtins.fromJSON (builtins.readFile ../../hosts/homelab/services/.homepage/homepage.json);
  in {
    services.homepage-dashboard = {
      inherit (homepageConfig) services;
      enable = lib.mkDefault true;
      listenPort = lib.mkDefault 8082;
      allowedHosts = lib.mkDefault "*";
      environmentFiles = [config.age.secrets."homepage.env".path];
      settings = {
        inherit (homepageConfig) layout;
        color = lib.mkDefault "slate";
        title = lib.mkDefault "Kike's Homelab";
        description = lib.mkDefault "A collection of services running on Kike's Homelab";
        hideVersion = lib.mkDefault true;
        useEqualHeights = lib.mkDefault true;
      };
    };
  };
}
