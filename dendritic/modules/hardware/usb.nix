_: {
  flake.nixosModules.hardware-usb = {
    boot.initrd.kernelModules = [
      "ehci_pci"
      "sd_mod"
      "usbhid"
      "usb_storage"
      "xhci_hcd"
      "xhci_pci"
    ];
  };
}
