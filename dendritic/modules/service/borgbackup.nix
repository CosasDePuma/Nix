{lib, ...}: {
  # Daily borg snapshot of the state of whichever services run on the host,
  # into a per-host repository on the NAS backups share. Live databases are
  # dumped first (borgbackup-dumps) so the archive holds a consistent copy
  # instead of files caught mid-write; restore from the dump, not the live
  # files next to it.
  flake.nixosModules.service-borgbackup = {
    config,
    pkgs,
    ...
  }: let
    jellyfin = config.services.jellyfin;
    komga = config.services.komga;
    qbittorrent = config.services.qbittorrent;
    headscale = config.services.headscale;
    containers = config.virtualisation.oci-containers.containers;

    hasPaperclip = containers ? paperclip;
    hasRakazo = containers ? rakazo-postgres;

    backend = config.virtualisation.oci-containers.backend;
    runtime = "${config.virtualisation.${backend}.package}/bin/${backend}";

    # Ephemeral: rewritten on every run, only ever read by borg.
    dumpDir = "/var/backup/borg";
    repo = config.services.borgbackup.jobs.backup.repo;

    paperclipDir = "/var/lib/paperclip/data";
    hasDumps = hasPaperclip || hasRakazo || (headscale.enable or false);
  in {
    services.borgbackup.jobs.backup = {
      startAt = lib.mkDefault "daily";
      # Catch up on a run missed while the host was down.
      persistentTimer = lib.mkDefault true;
      encryption.mode = lib.mkDefault "none";
      # Borg's "unknown unencrypted repository" guard only protects encrypted
      # repos from being swapped for plain ones; it is moot when the repo is
      # plain by design.
      environment.BORG_UNKNOWN_UNENCRYPTED_REPO_ACCESS_IS_OK = lib.mkIf (config.services.borgbackup.jobs.backup.encryption.mode == "none") "yes";
      compression = lib.mkDefault "auto,zstd";
      paths =
        lib.optionals (jellyfin.enable or false) [jellyfin.dataDir]
        ++ lib.optionals (komga.enable or false) [komga.stateDir]
        ++ lib.optionals (qbittorrent.enable or false) [qbittorrent.profileDir]
        ++ lib.optionals (headscale.enable or false) ["/var/lib/headscale"]
        ++ lib.optionals hasPaperclip ["/var/lib/paperclip"]
        ++ lib.optionals hasRakazo ["/var/lib/rakazo"]
        ++ lib.optionals hasDumps [dumpDir];
      exclude =
        lib.optionals hasPaperclip ["${paperclipDir}/instances/*/db"]
        ++ ["sh:**/node_modules"];
      prune.keep = {
        daily = lib.mkDefault 7;
        weekly = lib.mkDefault 4;
        monthly = lib.mkDefault 6;
      };
      repo = lib.mkDefault "/mnt/backups/homelab/${config.networking.hostName}";
    };

    systemd.services = lib.mkMerge [
      {
        # The job's sandbox bind-mounts the repository, so it has to exist
        # before the job's own init could create it, and borg refuses to init
        # into an existing directory: initialise it here, outside the sandbox.
        borgbackup-repo = {
          description = "Initialise the borg repository";
          unitConfig.RequiresMountsFor = [repo];
          serviceConfig.Type = "oneshot";
          script = ''
            [ -e ${repo}/config ] && exit 0
            rmdir ${repo} 2>/dev/null || true
            mkdir -p "$(dirname ${repo})"
            ${pkgs.borgbackup}/bin/borg init --encryption=${config.services.borgbackup.jobs.backup.encryption.mode} ${repo}
          '';
        };
        borgbackup-job-backup = {
          after = ["borgbackup-repo.service"];
          requires = ["borgbackup-repo.service"];
          unitConfig.RequiresMountsFor = [repo];
        };
      }
      (lib.mkIf hasDumps {
        borgbackup-dumps = {
          description = "Dump live databases for borg";
          serviceConfig = {
            Type = "oneshot";
            UMask = "0077";
          };
          script = lib.concatStringsSep "\n" (
            [
              "set -o pipefail"
              "rm -rf ${dumpDir}"
              "mkdir -p ${dumpDir}"
            ]
            ++ lib.optionals (headscale.enable or false) [
              "${pkgs.sqlite}/bin/sqlite3 ${headscale.settings.database.sqlite.path} \".backup '${dumpDir}/headscale.sqlite'\""
            ]
            ++ lib.optionals hasPaperclip [
              # Upstream's own backup command, run where the embedded
              # PostgreSQL lives; it writes into the container's data volume.
              ''
                rm -rf ${paperclipDir}/borg-dump
                ${runtime} exec -u node -w /app paperclip pnpm -s paperclipai db:backup --dir /paperclip/borg-dump --filename-prefix paperclip
                mv ${paperclipDir}/borg-dump/paperclip-*.sql.gz ${dumpDir}/paperclip.sql.gz
                rm -rf ${paperclipDir}/borg-dump
              ''
            ]
            ++ lib.optionals hasRakazo [
              "${runtime} exec rakazo-postgres pg_dumpall -U rakazo | ${pkgs.zstd}/bin/zstd -q -o ${dumpDir}/rakazo.sql.zst"
            ]
          );
        };
        borgbackup-job-backup = {
          after = ["borgbackup-dumps.service"];
          requires = ["borgbackup-dumps.service"];
        };
      })
    ];
  };
}
