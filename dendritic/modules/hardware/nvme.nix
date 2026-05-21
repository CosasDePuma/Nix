_: {
  flake.nixosModules.hardware-nvme = {
    boot.initrd.kernelModules = ["nvme"];
  };
}
