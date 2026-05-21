{lib, ...}: {
  flake.modules = {
    nixos.cpu-intel = {
      hardware = {
        cpu.intel.updateMicrocode = lib.mkDefault true;
        enableRedistributableFirmware = lib.mkDefault true;
      };
    };
  };
}
