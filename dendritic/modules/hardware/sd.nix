_: {
  flake.nixosModules.hardware-sd = {
    boot.initrd.kernelModules = ["sdhci_pci"];
  };
}
