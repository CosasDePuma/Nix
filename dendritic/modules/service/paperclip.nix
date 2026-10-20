{inputs, ...}: {
  # Paperclip (AI agent orchestration) from its published GHCR image, as in
  # upstream's docker/docker-compose.quickstart.yml: one container with the
  # embedded PostgreSQL, the agent CLIs and every bit of state under
  # /paperclip.
  flake.nixosModules.service-paperclip = {
    config,
    lib,
    pkgs,
    ...
  }: let
    stateDir = "/var/lib/paperclip";
    secretsDir = "${stateDir}/secrets";
    dataDir = "${stateDir}/data";
  in {
    imports = with inputs.self.nixosModules; [software-podman];

    virtualisation.oci-containers.containers.paperclip = {
      image = lib.mkDefault "ghcr.io/paperclipai/paperclip:2026.1012.0";
      environment = {
        PAPERCLIP_HOME = "/paperclip";
        PAPERCLIP_DEPLOYMENT_MODE = lib.mkDefault "authenticated";
        # Private: the first browser session can claim the instance, so
        # finish setup before letting anyone else reach it.
        PAPERCLIP_DEPLOYMENT_EXPOSURE = lib.mkDefault "private";
        # Auth callbacks, invite links and the hostname allowlist all derive
        # from this; hosts behind a TLS proxy set their public origin.
        PAPERCLIP_PUBLIC_URL = lib.mkDefault "http://localhost:3100";
      };
      environmentFiles = ["${secretsDir}/paperclip.env"];
      # The entrypoint chowns this to the image's node user (uid 1000).
      volumes = ["${dataDir}:/paperclip"];
      ports = ["3100:3100"];
      extraOptions = [
        "--security-opt=no-new-privileges:true"
        # Upstream's backstop against agent runs leaking processes.
        "--pids-limit=2048"
        # Runs get 30s to settle on shutdown, plus cleanup.
        "--stop-timeout=90"
      ];
    };

    networking.firewall.allowedTCPPorts = [3100];

    systemd.tmpfiles.rules = [
      "d ${stateDir} 0750 root root -"
      "d ${dataDir} 0750 1000 1000 -"
    ];

    systemd.services = {
      # Generated once on first boot and kept across rebuilds, so sessions
      # survive and nothing secret lands in the store.
      paperclip-secrets = {
        description = "Generate Paperclip secrets";
        wantedBy = ["multi-user.target"];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          UMask = "0077";
        };
        script = ''
          mkdir -p ${secretsDir}
          gen() {
            [ -s "${secretsDir}/$1" ] || ${pkgs.openssl}/bin/openssl rand -hex 32 > "${secretsDir}/$1"
          }
          gen better-auth-secret
          gen tool-action-signing-secret

          read -r auth < ${secretsDir}/better-auth-secret
          read -r signing < ${secretsDir}/tool-action-signing-secret
          {
            printf 'BETTER_AUTH_SECRET=%s\n' "$auth"
            printf 'PAPERCLIP_TOOL_ACTION_SIGNING_SECRET=%s\n' "$signing"
          } > ${secretsDir}/paperclip.env
        '';
      };

      "${config.virtualisation.oci-containers.backend}-paperclip" = {
        after = ["paperclip-secrets.service"];
        requires = ["paperclip-secrets.service"];
        serviceConfig.TimeoutStopSec = lib.mkDefault 120;
      };
    };
  };
}
