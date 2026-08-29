{lib, ...}: {
  flake.nixosModules.network-forwarding = {
    boot.kernel.sysctl = {
      "net.ipv4.conf.all.forwarding" = lib.mkDefault true;
      "net.ipv6.conf.all.forwarding" = lib.mkDefault true;
    };
  };
}
