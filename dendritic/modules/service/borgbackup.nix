_: {
  flake.nixosModules.service-borgbackup = {
    config,
    lib,
    ...
  }: {
    services.borgbackup.jobs."backup" = {
      startAt = lib.mkDefault "daily";
      encryption.mode = lib.mkDefault "none";
      compression = lib.mkDefault "auto,zstd";
      paths = lib.mkDefault [
        "/var/lib/jellyfin/config"
        "/var/lib/jellyfin/data"
        "/var/lib/jellyfin/metadata"
        "/var/lib/jellyfin/plugins"
        "/var/lib/jellyfin/root"
        "/var/lib/komga/database.sqlite"
      ];
      prune.keep = {
        daily = lib.mkDefault 1;
        weekly = lib.mkDefault 1;
        monthly = lib.mkDefault 1;
      };
      repo = lib.mkDefault "/mnt/backups/homelab/${config.networking.hostName}";
    };
  };
}
