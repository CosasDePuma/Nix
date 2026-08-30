{inputs, ...}: {
  # AzerothCore (WoW 3.3.5a) as a Podman stack. Images are custom-built by
  # .github/workflows/azerothcore-kikewtf.yml since the mod-playerbots fork
  # never publishes its own.
  flake.nixosModules.service-azerothcore = {
    config,
    lib,
    pkgs,
    ...
  }: let
    # Container name prefix, matches REALM_NAME below.
    prefix = "isekaiofwarcraft";
    acImage = name: lib.mkDefault "ghcr.io/cosasdepuma/nix:${prefix}-${lib.replaceStrings ["-"] [""] name}";

    # Single source of truth for the DB root credential.
    dbPassword = config.virtualisation.oci-containers.containers."${prefix}-database".environment.MYSQL_ROOT_PASSWORD;
    dbInfo = db: "${prefix}-database;3306;root;${dbPassword};acore_${db}";

    etcVolume = "ac-config:/azerothcore/env/dist/etc";
    logsVolume = "ac-logs:/azerothcore/env/dist/logs";
  in {
    imports = with inputs.self.nixosModules; [software-podman];

    virtualisation.oci-containers.containers = {
      "${prefix}-database" = {
        image = lib.mkDefault "docker.io/library/mysql:8.4";
        environment.MYSQL_ROOT_PASSWORD = lib.mkDefault "password";
        volumes = ["ac-database:/var/lib/mysql"];
        podman.sdnotify = lib.mkDefault "healthy";
        extraOptions = [
          "--health-cmd=mysqladmin ping -uroot -p${dbPassword} --silent"
          "--health-interval=5s"
          "--health-timeout=10s"
          "--health-retries=40"
          "--health-start-period=30s"
        ];
      };

      # One-shot: downloads WoW client data once, then exits every boot.
      "${prefix}-clientdatainit" = {
        image = acImage "client-data";
        volumes = ["ac-client-data:/azerothcore/env/dist/data"];
      };

      "${prefix}-dbimport" = {
        image = acImage "db-import";
        environment = {
          AC_DATA_DIR = "/azerothcore/env/dist/data";
          AC_LOGS_DIR = "/azerothcore/env/dist/logs";
          AC_LOGIN_DATABASE_INFO = dbInfo "auth";
          AC_WORLD_DATABASE_INFO = dbInfo "world";
          AC_CHARACTER_DATABASE_INFO = dbInfo "characters";
          # mod-playerbots needs its own database or worldserver won't start.
          AC_PLAYERBOTS_DATABASE_INFO = dbInfo "playerbots";
        };
        volumes = [etcVolume logsVolume];
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
        ports = ["3724:3724"];
        extraOptions = ["--tty"];
        # dependsOn only orders start attempts, not completion -- authserver
        # retries via Restart=on-failure until dbimport is actually done.
        dependsOn = ["${prefix}-database" "${prefix}-dbimport"];
      };

      "${prefix}-worldserver" = {
        image = acImage "worldserver";
        environment = {
          AC_DATA_DIR = "/azerothcore/env/dist/data";
          AC_LOGS_DIR = "/azerothcore/env/dist/logs";
          AC_LOGIN_DATABASE_INFO = dbInfo "auth";
          AC_WORLD_DATABASE_INFO = dbInfo "world";
          AC_CHARACTER_DATABASE_INFO = dbInfo "characters";
          # mod-playerbots needs its own database or worldserver won't start.
          AC_PLAYERBOTS_DATABASE_INFO = dbInfo "playerbots";
          # Without these, mod-spelldraft loops instead of defaulting (21k+
          # log lines, never boots).
          AC_SPELL_DRAFT_ENABLE = "1";
          AC_SPELL_DRAFT_ALLOW_SPELLS_IN_DRUID_FORMS = "0";
          # Same as spelldraft above: mod-aoe-loot rechecks these on every
          # loot event instead of defaulting once (1000+ log lines/boot).
          AC_AOELOOT_ENABLE = "1";
          AC_AOELOOT_MESSAGE = "1";

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

          # mod-hardcore's default exempts levels 1-9; MinLevel=1 makes it
          # true 1-79.
          AC_MOD_HARDCORE_ENABLE = "1";
          AC_MOD_HARDCORE_MIN_LEVEL_ENABLE = "1";
          AC_MOD_HARDCORE_MAX_LEVEL_ENABLE = "79";

          # AuctionHouseBot.GUIDs left unset -- needs a real (non-bot)
          # character's GUID once one exists.
          AC_AUCTION_HOUSE_BOT_ENABLE_SELLER = "1";

          # Wires up ALE's own log file (silently dropped otherwise).
          AC_LOGGER_ALE = "4,ALELog ALEConsole";
          AC_APPENDER_ALELOG = "2,5,0,ALE.log,w";
          AC_APPENDER_ALECONSOLE = "1,4,0,\"0 9 0 3 5 0\"";

          # ALE.ScriptPath defaults to relative "lua_scripts", resolved
          # against worldserver's real CWD (/azerothcore, not env/dist) --
          # use an absolute path instead.
          AC_ALE_SCRIPT_PATH = "/azerothcore/env/dist/lua_scripts";

          AC_MOTD = lib.mkDefault "Welcome to AzerothCore!";
        };
        volumes = [etcVolume logsVolume "ac-client-data:/azerothcore/env/dist/data/:ro"];
        ports = [
          "8085:8085" # world port, reached by game clients
          "127.0.0.1:7878:7878" # SOAP admin console, not for clients
        ];
        # Keeps tty/stdin attached for `podman attach` (GM console).
        extraOptions = ["--interactive" "--tty"];
        # clientdatainit excluded: its sdnotify races conmon and gets marked
        # failed even on success, so a hard Requires would block every boot.
        dependsOn = ["${prefix}-database" "${prefix}-dbimport"];
      };
    };

    systemd.services = {
      "podman-${prefix}-clientdatainit".serviceConfig.Restart = lib.mkForce "no";
      # One-shot like clientdatainit -- without Restart=no it loops until
      # start-limit-burst, breaking worldserver.
      "podman-${prefix}-dbimport".serviceConfig.Restart = lib.mkForce "no";
      "podman-${prefix}-worldserver".after = ["podman-${prefix}-clientdatainit.service"];

      # Re-runs ac-realmlist-config before every authserver attempt --
      # dbimport reseeds the realm row (undoing the fix) each retry.
      "podman-${prefix}-authserver" = {
        after = ["ac-realmlist-config.service"];
        requires = ["ac-realmlist-config.service"];
        # Default pacing retriggers dbimport/ac-realmlist-config too fast,
        # tripping their own start-limit-burst -- slow down.
        serviceConfig.RestartSec = lib.mkForce 10;
      };

      "ac-realmlist-config" = {
        description = "Configure AzerothCore realmlist address in database";
        after = ["podman-${prefix}-dbimport.service" "podman-${prefix}-database.service"];
        requires = ["podman-${prefix}-database.service"];
        wantedBy = ["multi-user.target"];
        environment = {
          REALM_ADDRESS = lib.mkDefault "127.0.0.1";
          REALM_NAME = lib.mkDefault "AzerothCore";
        };
        # No RemainAfterExit: must re-run every time something requires it.
        serviceConfig.Type = "oneshot";
        path = [pkgs.podman pkgs.coreutils];
        script = ''
          for _ in $(seq 1 30); do
            if podman exec ${prefix}-database mysqladmin ping -uroot -p${dbPassword} --silent 2>/dev/null; then
              break
            fi
            sleep 2
          done
          # flag=0 clears REALM_FLAG_OFFLINE, which nothing else here manages.
          podman exec ${prefix}-database mysql -uroot -p${dbPassword} -e \
            "UPDATE acore_auth.realmlist SET name = '$REALM_NAME', address = '$REALM_ADDRESS', localAddress = '$REALM_ADDRESS', flag = 0 WHERE id = 1;"
        '';
      };
    };
  };
}
