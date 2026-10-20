{inputs, ...}: {
  # Rakazo (self-hosted AI agents) from its published GHCR images, mirroring
  # upstream's infra/compose/docker-compose.images.yml. Needs the real Docker
  # engine, not Podman's compat socket: the supervisor drives the Docker API
  # directly (per-bot networks, API 1.45+ volume features, compose labels).
  flake.nixosModules.service-rakazo = {
    config,
    lib,
    pkgs,
    ...
  }: let
    tag = "v0.2.0";
    appImage = lib.mkDefault "ghcr.io/elie222/rakazo/app:${tag}";

    stateDir = "/var/lib/rakazo";
    secretsDir = "${stateDir}/secrets";
    # Bind mount instead of a named volume: the supervisor bind-mounts each
    # bot's home from here into its computer container.
    dataDir = "${stateDir}/data";

    containers = config.virtualisation.oci-containers.containers;

    # Single source of truth for the public origin: hosts set RAKAZO_HOST on
    # rakazo-web and the auth/CORS origins follow. localhost means no TLS
    # proxy in front, so fall back to upstream's loopback defaults.
    rakazoHost = containers.rakazo-web.environment.RAKAZO_HOST;
    origin =
      if rakazoHost == "localhost"
      then "http://127.0.0.1:5173"
      else "https://${rakazoHost}";

    hardening = {
      memory,
      pids,
    }: [
      "--init"
      "--security-opt=no-new-privileges:true"
      "--memory=${memory}"
      "--pids-limit=${toString pids}"
    ];

    appEnvironment = {
      NODE_ENV = "production";
      DATA_DIR = "/data";
      SANDBOX_PROVIDER = lib.mkDefault "docker";
      SANDBOX_SUPERVISOR_URL = "http://rakazo-supervisor:7091";
      SECRET_STORE = lib.mkDefault "encrypted";
      CLOUD_AGENT_PROVIDER = lib.mkDefault "none";
      WAKEUP_DRIVER = "graphile";
      AGENT_RUNTIME = "pi";
      LOG_LEVEL = lib.mkDefault "info";
      MAX_UPLOAD_SIZE_MB = lib.mkDefault "10";
    };
  in {
    imports = with inputs.self.nixosModules; [software-docker];

    virtualisation.oci-containers.containers = {
      rakazo-postgres = {
        image = lib.mkDefault "docker.io/library/postgres:16@sha256:e17e86066e5ef83e0952a9347f5c792b7ece00972e2aa787a6986f471b3dd3d5";
        environment = {
          POSTGRES_USER = "rakazo";
          POSTGRES_DB = "rakazo";
        };
        environmentFiles = ["${secretsDir}/postgres.env"];
        volumes = ["rakazo-pgdata:/var/lib/postgresql/data"];
        networks = ["rakazo-data"];
        extraOptions = hardening {
          memory = "2g";
          pids = 200;
        };
      };

      # Has the Docker socket, so it is root on this host: never publish it.
      rakazo-supervisor = {
        image = appImage;
        cmd = ["pnpm" "--filter" "@rakazo/sandbox-supervisor" "start"];
        user = "root";
        environment = {
          NODE_ENV = "production";
          DATA_DIR = "/data";
          SUPERVISOR_HOST = "0.0.0.0";
          SUPERVISOR_PORT = "7091";
          DOCKER_SOCKET = "/var/run/docker.sock";
          RAKAZO_COMPUTER_IMAGE = lib.mkDefault "ghcr.io/elie222/rakazo/computer:${tag}";
          RAKAZO_COMPUTER_MEMORY = lib.mkDefault "2g";
          RAKAZO_COMPUTER_CPUS = lib.mkDefault "2";
          RAKAZO_COMPUTER_PIDS_LIMIT = lib.mkDefault "2048";
          SANDBOX_COMMAND_TIMEOUT_MS = lib.mkDefault "300000";
          SANDBOX_SCREEN_NETWORK = "isolated";
          SANDBOX_COMPUTER_EGRESS = lib.mkDefault "open";
          LOG_LEVEL = lib.mkDefault "info";
          MAX_UPLOAD_SIZE_MB = lib.mkDefault "10";
        };
        environmentFiles = ["${secretsDir}/supervisor.env"];
        volumes = [
          "/var/run/docker.sock:/var/run/docker.sock"
          "${dataDir}:/data"
        ];
        networks = ["rakazo-app"];
        # The supervisor finds its compose project through these labels to
        # attach rakazo-web to each bot's isolated computer network.
        labels = {
          "com.docker.compose.project" = "rakazo";
          "com.docker.compose.service" = "supervisor";
        };
        extraOptions = hardening {
          memory = "512m";
          pids = 256;
        };
      };

      rakazo-api = {
        image = appImage;
        cmd = ["bash" "-lc" "pnpm --filter @rakazo/db exec prisma migrate deploy && pnpm --filter @rakazo/api start"];
        environment =
          appEnvironment
          // {
            API_HOST = "0.0.0.0";
            BETTER_AUTH_URL = lib.mkDefault origin;
            WEB_ORIGIN = lib.mkDefault origin;
            API_URL = lib.mkDefault origin;
            AUTH_PASSWORD_ENABLED = lib.mkDefault "true";
            # Only read on the API's first start; close it afterwards from the UI.
            SIGNUPS_ENABLED = lib.mkDefault "true";
          };
        environmentFiles = ["${secretsDir}/app.env"];
        volumes = ["${dataDir}:/data"];
        networks = ["rakazo-app" "rakazo-data"];
        dependsOn = ["rakazo-postgres" "rakazo-supervisor"];
        extraOptions =
          ["--cap-drop=ALL"]
          ++ hardening {
            memory = "1536m";
            pids = 256;
          };
      };

      rakazo-worker = {
        image = appImage;
        cmd = ["pnpm" "--filter" "@rakazo/worker" "start"];
        environment =
          appEnvironment
          // {
            # Upstream blanks these for the worker: it never signs sessions
            # nor proxies screens, so it does not get to hold those secrets.
            BETTER_AUTH_SECRET = "";
            SCREEN_PROXY_SECRET = "";
          };
        environmentFiles = ["${secretsDir}/app.env"];
        volumes = ["${dataDir}:/data"];
        networks = ["rakazo-app" "rakazo-data"];
        dependsOn = ["rakazo-api"];
        extraOptions =
          ["--cap-drop=ALL"]
          ++ hardening {
            memory = "2g";
            pids = 512;
          };
      };

      rakazo-web = {
        image = appImage;
        cmd = ["pnpm" "--filter" "@rakazo/web" "preview" "--host" "0.0.0.0" "--port" "5173"];
        environment = {
          NODE_ENV = "production";
          API_PROXY_TARGET = "http://rakazo-api:3100";
          RAKAZO_HOST = lib.mkDefault "localhost";
          RAKAZO_IMAGE_TAG = tag;
        };
        environmentFiles = ["${secretsDir}/web.env"];
        ports = ["5173:5173"];
        networks = ["rakazo-app"];
        labels = {
          "com.docker.compose.project" = "rakazo";
          "com.docker.compose.service" = "web";
        };
        dependsOn = ["rakazo-api"];
        extraOptions =
          ["--cap-drop=ALL"]
          ++ hardening {
            memory = "512m";
            pids = 128;
          };
      };
    };

    # TLS terminates on a reverse proxy in front (it is what the mobile app
    # and Better Auth's secure cookies need), which reaches the web port.
    networking.firewall.allowedTCPPorts = [5173];

    # App containers run as uid 1000 (upstream's data-init chowns to it).
    systemd.tmpfiles.rules = [
      "d ${stateDir} 0750 root root -"
      "d ${dataDir} 0750 1000 1000 -"
    ];

    systemd.services = lib.mkMerge [
      {
        # Same secrets install-images.sh generates, created once on first
        # boot and kept across rebuilds; nothing secret lands in the store.
        rakazo-secrets = {
          description = "Generate Rakazo secrets";
          wantedBy = ["multi-user.target"];
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            UMask = "0077";
          };
          script = ''
            mkdir -p ${secretsDir}
            gen() {
              [ -s "${secretsDir}/$1" ] || ${pkgs.openssl}/bin/openssl rand -hex "$2" > "${secretsDir}/$1"
            }
            gen postgres-password 16
            gen better-auth-secret 32
            gen encryption-key 32
            gen screen-proxy-secret 32
            gen supervisor-token 32

            read -r pg < ${secretsDir}/postgres-password
            read -r auth < ${secretsDir}/better-auth-secret
            read -r enc < ${secretsDir}/encryption-key
            read -r screen < ${secretsDir}/screen-proxy-secret
            read -r supervisor < ${secretsDir}/supervisor-token

            printf 'POSTGRES_PASSWORD=%s\n' "$pg" > ${secretsDir}/postgres.env
            printf 'SANDBOX_SUPERVISOR_TOKEN=%s\n' "$supervisor" > ${secretsDir}/supervisor.env
            printf 'SCREEN_PROXY_SECRET=%s\n' "$screen" > ${secretsDir}/web.env
            {
              printf 'DATABASE_URL=postgres://rakazo:%s@rakazo-postgres:5432/rakazo\n' "$pg"
              printf 'BETTER_AUTH_SECRET=%s\n' "$auth"
              printf 'ENCRYPTION_KEY=%s\n' "$enc"
              printf 'SCREEN_PROXY_SECRET=%s\n' "$screen"
              printf 'SANDBOX_SUPERVISOR_TOKEN=%s\n' "$supervisor"
            } > ${secretsDir}/app.env
          '';
        };

        # "data" is internal like upstream's: Postgres gets no route out.
        rakazo-networks = {
          description = "Create Rakazo Docker networks";
          after = ["docker.service"];
          requires = ["docker.service"];
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
          };
          script = let
            docker = "${config.virtualisation.docker.package}/bin/docker";
          in ''
            ${docker} network inspect rakazo-app >/dev/null 2>&1 || ${docker} network create rakazo-app
            ${docker} network inspect rakazo-data >/dev/null 2>&1 || ${docker} network create --internal rakazo-data
          '';
        };

        # The supervisor checks the computer image once at startup and keeps
        # failing if it was missing then, so fetch it first, riding out
        # transient registry errors (upstream gates it the same way).
        rakazo-computer-image = {
          description = "Pull the Rakazo computer image";
          after = ["docker.service" "network-online.target"];
          requires = ["docker.service"];
          wants = ["network-online.target"];
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
          };
          script = let
            docker = "${config.virtualisation.docker.package}/bin/docker";
            image = containers.rakazo-supervisor.environment.RAKAZO_COMPUTER_IMAGE;
          in ''
            for attempt in $(seq 1 10); do
              ${docker} image inspect ${image} >/dev/null 2>&1 && exit 0
              ${docker} pull ${image} && exit 0
              echo "pull attempt $attempt failed, retrying" >&2
              sleep $((attempt * 15))
            done
            exit 1
          '';
        };
        docker-rakazo-supervisor = {
          after = ["rakazo-computer-image.service"];
          requires = ["rakazo-computer-image.service"];
        };
      }
      (lib.genAttrs
        (map (name: "docker-rakazo-${name}") ["postgres" "supervisor" "api" "worker" "web"])
        (_: {
          after = ["rakazo-networks.service" "rakazo-secrets.service"];
          requires = ["rakazo-networks.service" "rakazo-secrets.service"];
        }))
    ];
  };
}
