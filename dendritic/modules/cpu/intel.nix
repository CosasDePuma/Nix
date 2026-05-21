{lib, ...}: {
  flake.nixosModules.cpu-intel = {
    boot.initrd.kernelModules = [
      "kvm-intel"
      "vmd"
    ];
    hardware = {
      cpu.intel.updateMicrocode = lib.mkDefault true;
      enableRedistributableFirmware = lib.mkDefault true;
    };
    powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
    services.thermald.enable = lib.mkDefault true;
  };
}
