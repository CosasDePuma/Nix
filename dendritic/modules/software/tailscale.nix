{lib, ...}: {
  flake.nixosModules.software-tailscale = {
    services.tailscale = {
      enable = lib.mkDefault true;
      openFirewall = lib.mkDefault true;
    };
  };
}
