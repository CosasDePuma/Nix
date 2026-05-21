{lib, ...}: {
  flake.modules = {
    nixos.boot-efi = {
      boot.loader.efi.canTouchEfiVariables = lib.mkDefault true;
    };
  };
}
