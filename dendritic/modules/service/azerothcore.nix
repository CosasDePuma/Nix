{inputs, ...}: {
  # AzerothCore (WoW 3.3.5a emulator) as a Podman container stack, mirroring
  # https://www.azerothcore.org/wiki/installation's Docker setup. The
  # mod-playerbots fork never publishes prebuilt images upstream (its
  # docker_build.yml only pushes when running on azerothcore/azerothcore-wotlk
  # itself), so these are built by .github/workflows/azerothcore-kikewtf.yml
  # with mod-playerbots, mod-ale and mod-spelldraft baked in.
  flake.nixosModules.service-azerothcore = {
    config,
    lib,
    ...
  }: let
    # Fully qualified: podman refuses to guess a registry for a short name
    # unless unqualified-search-registries is set globally, so this names
    # the registry explicitly instead of relying on that.
    acImage = name: lib.mkDefault "ghcr.io/cosasdepuma/nix:azerothcore-${name}";

    # Single source of truth for the DB root credential: every server reads
    # it back from ac-database (set once, below, with mkDefault) instead of
    # duplicating the literal, so overriding it in one place keeps them
    # all in sync.
    dbPassword = config.virtualisation.oci-containers.containers.ac-database.environment.MYSQL_ROOT_PASSWORD;
    dbInfo = db: "ac-database;3306;root;${dbPassword};acore_${db}";

    etcVolume = "ac-config:/azerothcore/env/dist/etc";
    logsVolume = "ac-logs:/azerothcore/env/dist/logs";
  in {
    imports = with inputs.self.nixosModules; [software-podman];

    virtualisation.oci-containers.backend = lib.mkDefault "podman";

    # netavark's built-in DNS resolves containers by name on this network,
    # so ac-db-import/ac-authserver/ac-worldserver can reach "ac-database"
    # without hand-rolling a dedicated podman network to get the same thing
    # docker-compose gives for free.
    virtualisation.podman.defaultNetwork.settings.dns_enabled = lib.mkDefault true;

    virtualisation.oci-containers.containers = {
      ac-database = {
        image = lib.mkDefault "docker.io/library/mysql:8.4";
        environment.MYSQL_ROOT_PASSWORD = lib.mkDefault "password";
        volumes = ["ac-database:/var/lib/mysql"];
        # No published port: only the containers on this network ever talk
        # to it, so there's no reason to expose the DB root account to the
        # host's interfaces.
        podman.sdnotify = lib.mkDefault "healthy";
        extraOptions = [
          "--health-cmd=mysqladmin ping -uroot -p${dbPassword} --silent"
          "--health-interval=5s"
          "--health-timeout=10s"
          "--health-retries=40"
          "--health-start-period=30s"
        ];
      };

      # One-shot: downloads the WoW client data (maps/dbc/vmaps/mmaps) the
      # servers need, then exits. Re-runs on every boot but the upstream
      # entrypoint skips the download once the volume is already populated.
      ac-client-data-init = {
        image = acImage "client-data";
        volumes = ["ac-client-data:/azerothcore/env/dist/data"];
      };

      ac-db-import = {
        image = acImage "db-import";
        environment = {
          AC_DATA_DIR = "/azerothcore/env/dist/data";
          AC_LOGS_DIR = "/azerothcore/env/dist/logs";
          AC_LOGIN_DATABASE_INFO = dbInfo "auth";
          AC_WORLD_DATABASE_INFO = dbInfo "world";
          AC_CHARACTER_DATABASE_INFO = dbInfo "characters";
          # mod-playerbots keeps its own database, separate from the three
          # above -- without this, worldserver refuses to start at all
          # ("Database Playerbots not specified in configuration file!").
          AC_PLAYERBOTS_DATABASE_INFO = dbInfo "playerbots";
        };
        volumes = [etcVolume logsVolume];
        # Waits for ac-database's healthcheck (podman.sdnotify = "healthy"
        # above), matching compose's `condition: service_healthy`.
        dependsOn = ["ac-database"];
      };

      ac-authserver = {
        image = acImage "authserver";
        environment = {
          AC_LOGS_DIR = "/azerothcore/env/dist/logs";
          AC_TEMP_DIR = "/azerothcore/env/dist/temp";
          AC_LOGIN_DATABASE_INFO = dbInfo "auth";
        };
        volumes = [etcVolume logsVolume];
        # Published on every interface: the realm's auth port has to be
        # reachable from wherever the game clients connect from. Podman's
        # own port-forwarding rules sit outside the NixOS firewall chain, so
        # nothing needs to be added to networking.firewall for this to work.
        ports = ["3724:3724"];
        extraOptions = ["--tty"];
        # There's no oci-containers primitive for "wait until this other
        # container finished running" (podman.sdnotify only distinguishes
        # started/healthy, and ac-db-import has no persistent health state
        # to poll). dependsOn still orders the start attempts; if
        # authserver comes up before the import has finished, it exits
        # non-zero against the still-incomplete schema and the default
        # Restart=on-failure retries it until ac-db-import is done.
        dependsOn = ["ac-database" "ac-db-import"];
      };

      ac-worldserver = {
        image = acImage "worldserver";
        environment = {
          AC_DATA_DIR = "/azerothcore/env/dist/data";
          AC_LOGS_DIR = "/azerothcore/env/dist/logs";
          AC_LOGIN_DATABASE_INFO = dbInfo "auth";
          AC_WORLD_DATABASE_INFO = dbInfo "world";
          AC_CHARACTER_DATABASE_INFO = dbInfo "characters";
          # mod-playerbots keeps its own database, separate from the three
          # above -- without this, worldserver refuses to start at all
          # ("Database Playerbots not specified in configuration file!").
          AC_PLAYERBOTS_DATABASE_INFO = dbInfo "playerbots";
        };
        volumes = [etcVolume logsVolume "ac-client-data:/azerothcore/env/dist/data/:ro"];
        ports = [
          "8085:8085" # world port, reached by game clients
          "127.0.0.1:7878:7878" # SOAP admin console, not for clients
        ];
        # Keeps stdin/tty attached so `podman attach ac-worldserver` gives a
        # working GM console, e.g. for the wiki's `account create` step.
        extraOptions = ["--interactive" "--tty"];
        # ac-client-data-init deliberately excluded from dependsOn: podman's
        # Type=notify + sdnotify=conmon races conmon's readiness signal
        # against the container's own exit for a job this short (it just
        # checks a version file and returns), so systemd marks the unit
        # "failed" even on a confirmed exit 0 -- a hard Requires here would
        # make that flakiness block worldserver every boot. The ordering
        # below (After only, via the plain systemd escape hatch) still runs
        # it first without depending on it succeeding.
        dependsOn = ["ac-database" "ac-db-import"];
      };
    };

    systemd.services = {
      "podman-ac-client-data-init".serviceConfig.Restart = lib.mkForce "no";
      "podman-ac-worldserver".after = ["podman-ac-client-data-init.service"];
    };
  };
}
