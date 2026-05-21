{lib, ...}: {
  flake.nixosModules.cpu-amd = {
    boot = {
      initrd.kernelModules = ["kvm-amd"];
      kernelParams = ["amd_pstate=active"];
    };
    hardware = {
      cpu.amd.updateMicrocode = lib.mkDefault true;
      enableRedistributableFirmware = lib.mkDefault true;
    };
    powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  };
}
