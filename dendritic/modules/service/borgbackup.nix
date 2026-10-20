{lib, ...}: {
  # Daily borg snapshot of the state of whichever media services run on the
  # host, into a per-host repository on the NAS backups share.
  flake.nixosModules.service-borgbackup = {config, ...}: let
    jellyfin = config.services.jellyfin;
    komga = config.services.komga;
  in {
    services.borgbackup.jobs.backup = {
      startAt = lib.mkDefault "daily";
      encryption.mode = lib.mkDefault "none";
      compression = lib.mkDefault "auto,zstd";
      paths =
        lib.optionals (jellyfin.enable or false) [jellyfin.dataDir]
        ++ lib.optionals (komga.enable or false) [komga.stateDir];
      prune.keep = {
        daily = lib.mkDefault 7;
        weekly = lib.mkDefault 4;
        monthly = lib.mkDefault 6;
      };
      repo = lib.mkDefault "/mnt/backups/homelab/${config.networking.hostName}";
    };
  };
}
