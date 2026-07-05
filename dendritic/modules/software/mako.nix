{lib, ...}: {
  flake = {
    homeManagerModules.software-mako = {
      services.mako.enable = lib.mkDefault true;
    };

    nixosModules.software-mako = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [mako];
    };
  };
}
