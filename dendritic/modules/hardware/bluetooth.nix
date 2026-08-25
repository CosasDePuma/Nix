{lib, ...}: {
  flake.nixosModules.hardware-bluetooth = _: {
    hardware.bluetooth.enable = lib.mkDefault true;
  };
}
