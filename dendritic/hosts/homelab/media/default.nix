{inputs, ...}: {
  flake.nixosModules.media = {
    config,
    pkgs,
    ...
  }: {
    imports = with inputs.self.nixosModules; [
      server-defaults
      (inputs.self.factory.homelab-user {
        name = "media";
        description = "Media management user";
        home = "/home/users/media";
        authorizedKeysFile = ./.ssh/authorized_keys;
      })
    ];

    age.secrets."smb.creds".file = ./.smb/smb.creds.age;

    environment.systemPackages = with pkgs; [
      cifs-utils
      mediainfo
      jellyfin-web
      jellyfin-ffmpeg
      wget
    ];

    fileSystems = builtins.listToAttrs (
      builtins.map
      (share: {
        name = "/mnt/${share}";
        value = {
          device = "//192.168.1.3/${share}";
          fsType = "cifs";
          options = [
            "credentials=${config.age.secrets."smb.creds".path}"
            "noauto"
            "x-systemd.automount"
            "x-systemd.device-timeout=5s"
            "x-systemd.idle-timeout=60"
            "x-systemd.mount-timeout=5s"
          ];
        };
      })
      [
        "backups"
        "media"
      ]
    );

    networking = {
      hostName = "media";
      hostId = builtins.substring 0 8 (builtins.hashString "md5" "media");
      usePredictableInterfaceNames = false;
      interfaces."eth0" = {
        useDHCP = false;
        ipv4.addresses = [
          {
            address = "10.0.10.3";
            prefixLength = 24;
          }
        ];
      };
      defaultGateway = {
        interface = "eth0";
        address = "10.0.10.254";
      };
      domain = "home";
      search = ["home"];
      nameservers = ["10.0.10.254"];
      firewall = {
        enable = true;
        allowedTCPPorts = [
          8096
          config.services.komga.settings.server.port
          config.services.prowlarr.settings.server.port
          config.services.qbittorrent.webuiPort
          config.services.qbittorrent.torrentingPort
          config.services.radarr.settings.server.port
          config.services.sonarr.settings.server.port
        ];
        allowedUDPPorts = [
          config.services.qbittorrent.torrentingPort
        ];
      };
    };

    nixpkgs.config.allowUnfree = false;

    services = {
      borgbackup.jobs."backup" = {
        startAt = "daily";
        encryption.mode = "none";
        compression = "auto,zstd";
        paths = [
          "/var/lib/jellyfin/config"
          "/var/lib/jellyfin/data"
          "/var/lib/jellyfin/metadata"
          "/var/lib/jellyfin/plugins"
          "/var/lib/jellyfin/root"
          "/var/lib/komga/database.sqlite"
        ];
        prune.keep = {
          daily = 1;
          weekly = 1;
          monthly = 1;
        };
        repo = "/mnt/backups/homelab/${config.networking.hostName}";
      };

      jellyfin.enable = true;

      komga = {
        enable = true;
        settings = {
          server.port = 25600;
          servlet.session.timeout = "7d";
          delete-empty-collections = true;
          delete-empty-read-lists = true;
        };
      };

      qbittorrent = {
        enable = true;
        user = "root";
        webuiPort = 8080;
        torrentingPort = 61640;
        serverConfig = {
          LegalNotice.Accepted = true;
          Preferences = {
            WebUI = {
              Username = "user";
              Password_PBKDF2 = "@ByteArray(+rg1RhvMUar4o8t10fvXgw==:EezNM70+FoG2R88DGjP9STsVT4LrjoySmyRmS6W2sWJRtQvHsE9sydYMJwSeQ+rs7HWwsg5+syC2KcfzzB0i+Q==)";
            };
            General.Locale = "en";
          };
        };
      };

      radarr = {
        enable = true;
        user = "root";
        settings.server = {
          urlbase = "/movies";
          port = 7878;
        };
      };

      sonarr = {
        enable = true;
        user = "root";
        settings.server = {
          urlbase = "/series";
          port = 8989;
        };
      };
    };

    system.autoUpgrade = {
      enable = false;
      flake = "github:cosasdepuma/nix";
      dates = "daily";
      operation = "switch";
      persistent = true;
    };
  };

  flake.nixosConfigurations = inputs.self.lib.mkNixos "x86_64-linux" "media";
}
