{lib, ...}: {
  # Out-of-band console access (e.g. Proxmox `qm terminal`) for hosts whose
  # only other access path is SSH -- lets a stuck/unreachable sshd still be
  # diagnosed from the hypervisor.
  flake.nixosModules.hardware-serial = {
    boot.kernelParams = ["console=ttyS0,115200n8" "console=tty0"];
    systemd.services."serial-getty@ttyS0".enable = lib.mkDefault true;
  };
}
