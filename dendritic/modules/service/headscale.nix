{lib, ...}: {
  # Coordination server for Tailscale clients. server_url and
  # tls_letsencrypt_hostname are genuinely per-deployment (they're the
  # public domain this instance answers on) and are left for the host to
  # set, same as ddclient's domains/zone.
  flake.nixosModules.service-headscale = {
    services.headscale = {
      enable = lib.mkDefault true;
      port = lib.mkDefault 443;
      address = lib.mkDefault "0.0.0.0";
      settings = {
        # Avoids needing port 80 open too: the same 443 the control API
        # already listens on doubles as the ACME challenge port.
        tls_letsencrypt_challenge_type = lib.mkDefault "TLS-ALPN-01";
        dns = {
          magic_dns = lib.mkDefault false;
          nameservers.global = lib.mkDefault ["1.1.1.1" "8.8.8.8"];
        };
      };
    };
  };
}
