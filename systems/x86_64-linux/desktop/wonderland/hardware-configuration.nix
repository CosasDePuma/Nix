{
  config ? throw "not imported as module",
  lib ? throw "not imported as module",
  pkgs ? throw "not imported as module",
  modulesPath ? throw "not imported as module",
  ...
}:
{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot = {
    initrd = {
      availableKernelModules = [
        "xhci_pci"
        "ahci"
        "nvme"
        "usb_storage"
        "usbhid"
        "sd_mod"
      ];
      kernelModules = [ "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" ];
    };
    kernelModules = [ "kvm-amd" ];
    extraModulePackages = [ ];
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/315513fb-f22a-415e-ac0f-026f55a3aa8d";
      fsType = "ext4";
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/AE66-D1D8";
      fsType = "vfat";
      options = [
        "fmask=0077"
        "dmask=0077"
      ];
    };
  };

  swapDevices = [ ];
}
