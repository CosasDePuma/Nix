{lib, ...}: {
  flake.nixosModules.software-networkmanager = {
    networking.networkmanager.enable = lib.mkDefault true;
    # TODO: Create software-openvpn module and add networking.networkmanager.plugins if nm is enabled
  };
}
