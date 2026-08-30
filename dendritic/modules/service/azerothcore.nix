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
    pkgs,
    ...
  }: let
    # Container name prefix -- matches the realm name (REALM_NAME below).
    # Only the container/systemd-unit identity changes when this is bumped.
    prefix = "isekaiofwarcraft";
    acImage = name: lib.mkDefault "ghcr.io/cosasdepuma/nix:${prefix}-${lib.replaceStrings ["-"] [""] name}";

    # Single source of truth for the DB root credential: every server reads
    # it back from the database container (set once, below, with mkDefault)
    # instead of duplicating the literal, so overriding it in one place
    # keeps them all in sync.
    dbPassword = config.virtualisation.oci-containers.containers."${prefix}-database".environment.MYSQL_ROOT_PASSWORD;
    dbInfo = db: "${prefix}-database;3306;root;${dbPassword};acore_${db}";

    etcVolume = "ac-config:/azerothcore/env/dist/etc";
    logsVolume = "ac-logs:/azerothcore/env/dist/logs";
  in {
    imports = with inputs.self.nixosModules; [software-podman];

    virtualisation.oci-containers.backend = lib.mkDefault "podman";

    # netavark's built-in DNS resolves containers by name on this network,
    # so the db-import/authserver/worldserver containers can reach the
    # database container without hand-rolling a dedicated podman network to
    # get the same thing docker-compose gives for free.
    virtualisation.podman.defaultNetwork.settings.dns_enabled = lib.mkDefault true;

    virtualisation.oci-containers.containers = {
      "${prefix}-database" = {
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
      "${prefix}-client-data-init" = {
        image = acImage "client-data";
        volumes = ["ac-client-data:/azerothcore/env/dist/data"];
      };

      "${prefix}-db-import" = {
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
        # Waits for the database container's healthcheck (podman.sdnotify =
        # "healthy" above), matching compose's `condition: service_healthy`.
        dependsOn = ["${prefix}-database"];
      };

      "${prefix}-authserver" = {
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
        # started/healthy, and db-import has no persistent health state to
        # poll). dependsOn still orders the start attempts; if authserver
        # comes up before the import has finished, it exits non-zero
        # against the still-incomplete schema and the default
        # Restart=on-failure retries it until db-import is done.
        dependsOn = ["${prefix}-database" "${prefix}-db-import"];
      };

      "${prefix}-worldserver" = {
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
          # Without these two, mod-spelldraft doesn't just fall back to a
          # default and move on like every other missing-property warning --
          # it spins in a tight retry loop (21k+ identical log lines and
          # climbing CPU/network use within 2 minutes, never finishing boot).
          # Values match what the warning itself suggests.
          AC_SPELL_DRAFT_ENABLE = "1";
          AC_SPELL_DRAFT_ALLOW_SPELLS_IN_DRUID_FORMS = "0";

          # 5x leveling speed, 2x item drops.
          AC_RATE_XP_KILL = "5";
          AC_RATE_XP_QUEST = "5";
          AC_RATE_XP_EXPLORE = "5";
          AC_RATE_DROP_ITEM_POOR = "2";
          AC_RATE_DROP_ITEM_NORMAL = "2";
          AC_RATE_DROP_ITEM_UNCOMMON = "2";
          AC_RATE_DROP_ITEM_RARE = "2";
          AC_RATE_DROP_ITEM_EPIC = "2";
          AC_RATE_DROP_ITEM_LEGENDARY = "2";
          AC_RATE_DROP_ITEM_ARTIFACT = "2";
          AC_RATE_DROP_ITEM_REFERENCED = "2";

          # mod-hardcore: permadeath from level 1 to 79 (not 80/max) -- the
          # mod's own default leaves 1-9 exempt (MinLevel.Enable = 10), so
          # this has to be set explicitly to actually cover 1-79.
          AC_MOD_HARDCORE_ENABLE = "1";
          AC_MOD_HARDCORE_MIN_LEVEL_ENABLE = "1";
          AC_MOD_HARDCORE_MAX_LEVEL_ENABLE = "79";

          # mod-ah-bot-plus: enables the seller side, but AuctionHouseBot.GUIDs
          # (which character drives it) is deliberately left unset here -- it
          # has to be a real, non-bot character's GUID (the mod's own README
          # warns using a playerbot character may crash the server), which
          # only exists after someone creates one in-game.
          AC_AUCTION_HOUSE_BOT_ENABLE_SELLER = "1";

          # mod-spelldraft's level-up popup never fires and the DB it
          # should seed (prestige_stats) stays empty, with zero Eluna/ALE
          # log output either way -- AzerothCore silently drops LOG_INFO
          # calls for a logger category that has no Logger.*/Appender.*
          # entries configured, so this isn't proof Eluna is failing, it's
          # proof its output has nowhere to go. Wire up its own log file so
          # the *next* investigation has real evidence instead of silence.
          AC_LOGGER_ALE = "4,ALELog ALEConsole";
          AC_APPENDER_ALELOG = "2,5,0,ALE.log,w";
          AC_APPENDER_ALECONSOLE = "1,4,0,\"0 9 0 3 5 0\"";

          # The actual bug, found via /proc/1/cwd on the running container:
          # ALE.ScriptPath defaults to the bare relative string "lua_scripts",
          # which Eluna resolves against worldserver's real CWD -- which is
          # /azerothcore, NOT /azerothcore/env/dist (unlike AC_DATA_DIR/
          # AC_LOGS_DIR above, which are absolute paths we set ourselves).
          # The lua_scripts/ we bundle into the image at env/dist/lua_scripts
          # was one directory level too deep for Eluna to ever find it --
          # nothing was wrong with Eluna or the scripts themselves. Point at
          # it with an absolute path instead of relying on CWD.
          AC_ALE_SCRIPT_PATH = "/azerothcore/env/dist/lua_scripts";

          AC_MOTD = lib.mkDefault "Welcome to AzerothCore!";
        };
        volumes = [etcVolume logsVolume "ac-client-data:/azerothcore/env/dist/data/:ro"];
        ports = [
          "8085:8085" # world port, reached by game clients
          "127.0.0.1:7878:7878" # SOAP admin console, not for clients
        ];
        # Keeps stdin/tty attached so `podman attach <name>-worldserver`
        # gives a working GM console, e.g. for the wiki's `account create`
        # step.
        extraOptions = ["--interactive" "--tty"];
        # client-data-init deliberately excluded from dependsOn: podman's
        # Type=notify + sdnotify=conmon races conmon's readiness signal
        # against the container's own exit for a job this short (it just
        # checks a version file and returns), so systemd marks the unit
        # "failed" even on a confirmed exit 0 -- a hard Requires here would
        # make that flakiness block worldserver every boot. The ordering
        # below (After only, via the plain systemd escape hatch) still runs
        # it first without depending on it succeeding.
        dependsOn = ["${prefix}-database" "${prefix}-db-import"];
      };
    };

    systemd.services = {
      "podman-${prefix}-client-data-init".serviceConfig.Restart = lib.mkForce "no";
      # One-shot like client-data-init above: without this it defaults to
      # Restart=always, so it keeps re-running (successfully) after its job
      # is done until it trips systemd's start-limit-burst -- which then
      # cascades into worldserver refusing to start at all, since that unit
      # depends on this one.
      "podman-${prefix}-db-import".serviceConfig.Restart = lib.mkForce "no";
      "podman-${prefix}-worldserver".after = ["podman-${prefix}-client-data-init.service"];

      # Every authserver (re)start also retriggers db-import as its own
      # dependency (dependsOn above) -- and db-import's reference data
      # reseeds the realmlist row, silently undoing ac-realmlist-config's
      # fix if that only ran once at boot. Requiring it here re-runs it
      # before every authserver start attempt, not just the first.
      "podman-${prefix}-authserver" = {
        after = ["ac-realmlist-config.service"];
        requires = ["ac-realmlist-config.service"];
        # Default restart pacing (near-instant) retriggers db-import and
        # ac-realmlist-config so many times per second on a genuine cold
        # start that THEY trip systemd's own start-limit-burst before ever
        # getting a clean run in -- a cascading failure between three
        # units, found live while debugging why authserver stayed down
        # even after the realmlist row itself was confirmed correct.
        # Spacing attempts out gives the whole chain time to actually
        # finish once instead of racing it forever.
        serviceConfig.RestartSec = lib.mkForce 10;
      };

      "ac-realmlist-config" = {
        description = "Configure AzerothCore realmlist address in database";
        after = ["podman-${prefix}-db-import.service" "podman-${prefix}-database.service"];
        requires = ["podman-${prefix}-database.service"];
        wantedBy = ["multi-user.target"];
        environment = {
          REALM_ADDRESS = lib.mkDefault "127.0.0.1";
          REALM_NAME = lib.mkDefault "AzerothCore";
        };
        # No RemainAfterExit: this needs to genuinely re-run every time
        # something requires it (see podman-${prefix}-authserver above),
        # not just report "already satisfied" after the first boot.
        serviceConfig.Type = "oneshot";
        path = [pkgs.podman pkgs.coreutils];
        script = ''
          for _ in $(seq 1 30); do
            if podman exec ${prefix}-database mysqladmin ping -uroot -p${dbPassword} --silent 2>/dev/null; then
              break
            fi
            sleep 2
          done
          # flag=0 clears REALM_FLAG_OFFLINE -- found the hard way: nothing
          # here ever managed that column, so a stale flag (2, set by
          # whatever originally seeded this row) sat there invisibly until
          # authserver did a genuine cold start against it and refused to
          # list the realm at all ("No valid realms specified").
          podman exec ${prefix}-database mysql -uroot -p${dbPassword} -e \
            "UPDATE acore_auth.realmlist SET name = '$REALM_NAME', address = '$REALM_ADDRESS', localAddress = '$REALM_ADDRESS', flag = 0 WHERE id = 1;"
        '';
      };
    };
  };
}
