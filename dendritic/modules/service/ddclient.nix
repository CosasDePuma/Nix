{lib, ...}: {
  # Dynamic DNS updater. domains/zone/passwordFile are genuinely
  # per-deployment (they're the public domain and Cloudflare credential
  # this instance updates) and are left for the host to set, same as
  # headscale's server_url/tls_letsencrypt_hostname.
  flake.nixosModules.service-ddclient = {
    services.ddclient = {
      enable = lib.mkDefault true;
      interval = lib.mkDefault "1h";
      protocol = lib.mkDefault "cloudflare";
      verbose = lib.mkDefault true;
    };
  };
}
