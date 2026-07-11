{lib, ...}: {
  flake.nixosModules.service-n8n = {
    services.n8n = {
      enable = lib.mkDefault true;
      environment.WEBHOOK_URL = lib.mkDefault "https://automate.kike.wtf";
    };
  };
}
