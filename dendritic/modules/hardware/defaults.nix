{lib, ...}: {
  flake.nixosModules.hardware-defaults = {modulesPath, ...}: {
    imports = [(modulesPath + "/installer/scan/not-detected.nix")];
    hardware.enableAllHardware = lib.mkDefault true;
  };
}
