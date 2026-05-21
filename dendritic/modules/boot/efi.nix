{lib, ...}: {
  flake.nixosModules.boot-efi = {
    boot.loader.efi.canTouchEfiVariables = lib.mkDefault true;
  };
}
