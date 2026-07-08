{lib, ...}: {
  flake.nixosModules.network-firewall = {
    networking.firewall = {
      allowPing = lib.mkDefault false;
      enable = lib.mkDefault true;
    };
  };
}
