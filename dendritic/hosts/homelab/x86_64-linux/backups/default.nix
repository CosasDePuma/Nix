{inputs, ...}: {
  # Not a VM: the client side of the NAS "backups" share. A guest that
  # imports this mounts the share and runs service-borgbackup into its own
  # repository there. The credentials are readable by root only, never by
  # the containers a guest runs.
  flake.nixosModules.homelab-backups = {
    config,
    pkgs,
    ...
  }: {
    imports = with inputs.self.nixosModules; [service-borgbackup];

    age.secrets."smb-creds".file = ./.smb/smb.creds.age;
    environment.systemPackages = with pkgs; [cifs-utils];

    fileSystems."/mnt/backups" = {
      device = "//192.168.1.3/backups";
      fsType = "cifs";
      options = [
        "credentials=${config.age.secrets."smb-creds".path}"
        "noauto"
        "x-systemd.automount"
        "x-systemd.device-timeout=5s"
        "x-systemd.idle-timeout=60"
        "x-systemd.mount-timeout=5s"
      ];
    };
  };
}
