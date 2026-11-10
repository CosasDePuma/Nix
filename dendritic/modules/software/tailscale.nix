{lib, ...}: {
  flake = {
    darwinModules.software-tailscale = {
      homebrew.casks = ["tailscale-app"];
    };

    nixosModules.software-tailscale = {
      services.tailscale = {
        enable = lib.mkDefault true;
        openFirewall = lib.mkDefault true;
      };
    };
  };
}
