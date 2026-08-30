{lib, ...}: {
  # DHCP/DNS server. address/interface/dhcp-range/dhcp-option are genuinely
  # per-deployment (they're this host's own VLANs and domain) and are left
  # for the host to set, same as headscale's server_url.
  flake.nixosModules.service-dnsmasq = {
    services.dnsmasq = {
      enable = lib.mkDefault true;
      resolveLocalQueries = lib.mkDefault false;
      settings = {
        bind-dynamic = lib.mkDefault true;
        cache-size = lib.mkDefault 1000;
        domain-needed = lib.mkDefault true;
        bogus-priv = lib.mkDefault true;
        no-hosts = lib.mkDefault true;
        no-resolv = lib.mkDefault true;
        no-poll = lib.mkDefault true;
        server = lib.mkDefault ["1.1.1.1" "8.8.8.8"];
      };
    };
  };
}
