{lib, ...}: {
  flake.nixosModules.service-komga = {
    services.komga = {
      enable = lib.mkDefault true;
      settings = {
        server.port = lib.mkDefault 25600;
        servlet.session.timeout = lib.mkDefault "7d";
        delete-empty-collections = lib.mkDefault true;
        delete-empty-read-lists = lib.mkDefault true;
      };
    };
  };
}
