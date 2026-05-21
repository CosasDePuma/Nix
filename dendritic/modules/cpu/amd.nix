{lib, ...}: {
  flake.modules = {
    nixos.cpu-amd = {
      hardware = {
        cpu.amd.updateMicrocode = lib.mkDefault true;
        enableRedistributableFirmware = lib.mkDefault true;
      };
    };
  };
}
