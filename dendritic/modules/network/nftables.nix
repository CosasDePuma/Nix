{lib, ...}: {
  # Hosts that hand-write their own ruleset (routers, firewalls) import this
  # instead of network-firewall: the two are mutually exclusive ways of
  # managing the same iptables/nftables chains.
  flake.nixosModules.network-nftables = {
    networking = {
      firewall.enable = lib.mkDefault false;
      nat.enable = lib.mkDefault false;
      nftables.enable = lib.mkDefault true;
    };
  };
}
