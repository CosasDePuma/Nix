{
  inputs,
  lib,
  ...
}: {
  flake.nixosModules.software-qemu = {pkgs, ...}: {
    imports = [inputs.self.nixosModules.software-dnsmasq];
    boot.initrd.kernelModules = [
      "virtio_blk"
      "virtio_pci"
      "virtio_scsi"
    ];
    environment.systemPackages = with pkgs; [
      spice
      spice-gtk
      spice-protocol
      virt-viewer
    ];
    programs.virt-manager.enable = lib.mkDefault true;
    networking.firewall.trustedInterfaces = lib.mkDefault ["virbr0"];
    virtualisation.libvirtd = {
      enable = lib.mkDefault true;
      qemu = {
        package = lib.mkDefault pkgs.qemu_kvm;
        runAsRoot = lib.mkDefault true;
        swtpm.enable = lib.mkDefault true;
        vhostUserPackages = lib.mkDefault (with pkgs; [virtiofsd]);
      };
    };
  };
}
