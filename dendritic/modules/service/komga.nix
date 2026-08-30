{lib, ...}: {
  flake.nixosModules.service-komga = {
    services.komga = {
      enable = lib.mkDefault true;
      openFirewall = lib.mkDefault true;
      settings = {
        server.port = lib.mkDefault 25600;
        delete-empty-collections = lib.mkDefault true;
        delete-empty-read-lists = lib.mkDefault true;
        servlet.session.timeout = lib.mkDefault "7d";
      };
    };
  };
}
