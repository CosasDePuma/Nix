{lib, ...}: {
  flake.modules = {
    nixos.hardware-defaults = {
      hardware.enableAllHardware = lib.mkDefault true;
    };
  };
}
