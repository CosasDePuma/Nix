{
  config ? throw "not imported as module",
  lib ? throw "not imported as module",
  pkgs ? throw "not imported as module",
  stateVersion ? "25.05",
  ...
}:
{
  # ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  # ┃                   Boot                    ┃
  # ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

  boot.loader.grub.enable = true;

  # ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  # ┃                   Disko                   ┃
  # ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

  disko.devices = {
    disk."disk0" = {
      device = "/dev/sda";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          BOOT = {
            size = "1M";
            type = "EF02";
          };
          NIXOS = {
            size = "100%";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
              extraArgs = [
                "-L"
                "NIXOS"
              ];
            };
          };
        };
      };
    };
    nodev."/tmp" = {
      fsType = "tmpfs";
      mountOptions = [
        "noexec"
        "size=1G"
      ];
    };
  };

  # ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  # ┃                Environment                ┃
  # ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

  environment.systemPackages = with pkgs; [
    cifs-utils
    mediainfo
    jellyfin-web
    jellyfin-ffmpeg
    wget
  ];

  # ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  # ┃               Filesystems                 ┃
  # ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

  fileSystems = {
    "/mnt/backups" = {
      device = "//192.168.1.3/backups";
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
    "/mnt/media" = {
      device = "//192.168.1.3/media";
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
  };

  # ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  # ┃                 Hardware                  ┃
  # ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

  hardware.enableAllHardware = true;

  # ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  # ┃                Inputs: Age                ┃
  # ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

  age = {
    identityPaths = builtins.map (key: key.path) config.services.openssh.hostKeys;
    secrets."smb.creds".file = ./.smb/smb.creds.age;
  };

  # ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  # ┃                Networking                 ┃
  # ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

  networking = {
    # --- host
    hostName = "media";
    hostId = builtins.substring 0 8 (builtins.hashString "md5" config.networking.hostName);
    # --- interfaces
    usePredictableInterfaceNames = false;
    interfaces = {
      # --- physical interfaces
      "eth0" = {
        useDHCP = false;
        ipv4.addresses = [
          {
            address = "10.0.10.3";
            prefixLength = 24;
          }
        ];
      };
    };
    # --- gateway
    defaultGateway = {
      interface = "eth0";
      address = "10.0.10.254";
    };
    # --- dns
    domain = "home";
    search = [ "home" ];
    nameservers = [ "10.0.10.254" ];
    # --- firewall
    firewall = {
      enable = true;
      allowedTCPPorts = [
        8096
        64022
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

  # ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  # ┃                  Nixpkgs                  ┃
  # ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

  nixpkgs.config.allowUnfree = false;

  # ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  # ┃                  Security                 ┃
  # ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

  security = {
    pam = {
      sshAgentAuth.enable = true;
      services."sudo".sshAgentAuth = true;
    };
    sudo-rs = {
      enable = true;
      execWheelOnly = true;
    };
  };

  # ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  # ┃                 Services                  ┃
  # ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

  services = {

    # ┌──────────────────────────────────────┐
    # │                 Borg                 │
    # └──────────────────────────────────────┘

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

    # ┌──────────────────────────────────────┐
    # │               Jellyfin               │
    # └──────────────────────────────────────┘

    jellyfin = {
      enable = true;
    };

    # ┌──────────────────────────────────────┐
    # │                 Komga                │
    # └──────────────────────────────────────┘

    komga = {
      enable = true;
      settings = {
        server.port = 25600;
        servlet.session.timeout = "7d";
        delete-empty-collections = true;
        delete-empty-read-lists = true;
      };
    };

    # ┌──────────────────────────────────────┐
    # |              qBitTorrent             │
    # └──────────────────────────────────────┘

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

    # ┌──────────────────────────────────────┐
    # │                Radarr                │
    # └──────────────────────────────────────┘

    radarr = {
      enable = true;
      user = "root";
      settings.server = {
        urlbase = "/movies";
        port = 7878;
      };
    };

    # ┌──────────────────────────────────────┐
    # │                Sonarr                │
    # └──────────────────────────────────────┘

    sonarr = {
      enable = true;
      user = "root";
      settings.server = {
        urlbase = "/series";
        port = 8989;
      };
    };

    # ┌──────────────────────────────────────┐
    # │                OpenSSH               │
    # └──────────────────────────────────────┘

    openssh = {
      enable = true;
      allowSFTP = true;
      authorizedKeysInHomedir = false;
      banner = builtins.readFile ./.ssh/banner.txt;
      listenAddresses = [
        {
          addr = "0.0.0.0";
          port = 64022;
        }
      ];
      ports = [ ];
      startWhenNeeded = true;
      settings = {
        AllowUsers = lib.attrsets.mapAttrsToList (name: _: name) (
          lib.attrsets.filterAttrs (_: v: builtins.elem "sshuser" v.extraGroups) config.users.users
        );
        AuthorizedPrincipalsFile = "none";
        ChallengeResponseAuthentication = false;
        Ciphers = [
          "chacha20-poly1305@openssh.com"
          "aes256-gcm@openssh.com"
          "aes128-gcm@openssh.com"
          "aes256-ctr"
          "aes192-ctr"
          "aes128-ctr"
        ];
        ClientAliveInterval = 300;
        GatewayPorts = "no";
        IgnoreRhosts = true;
        KbdInteractiveAuthentication = false;
        KexAlgorithms = [
          "curve25519-sha256@libssh.org"
          "diffie-hellman-group16-sha512"
          "diffie-hellman-group18-sha512"
        ];
        LogLevel = "VERBOSE";
        LoginGraceTime = "30";
        Macs = [
          "hmac-sha2-512-etm@openssh.com"
          "hmac-sha2-256-etm@openssh.com"
          "umac-128-etm@openssh.com"
        ];
        MaxAuthTries = 3;
        MaxSessions = 5;
        MaxStartups = "10:30:100";
        PasswordAuthentication = false;
        PermitEmptyPasswords = false;
        PermitRootLogin = "no";
        PrintMotd = false;
        StrictModes = true;
        UseDns = false;
        UsePAM = true;
        X11Forwarding = false;
      };
    };

  };

  # ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  # ┃                  System                   ┃
  # ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

  system = { inherit stateVersion; };

  # ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  # ┃                   Users                   ┃
  # ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

  users = {
    mutableUsers = false;
    groups = {
      sshuser = { };
      users = { };
    };
    users.media = {
      isNormalUser = true;
      description = "Media management user";
      initialPassword = null;
      home = "/home/users/media";
      uid = 1000;
      group = "users";
      useDefaultShell = true;
      extraGroups = [
        "wheel"
        "sshuser"
      ];
      openssh.authorizedKeys.keys = lib.strings.splitString "\n" (
        builtins.readFile ./.ssh/authorized_keys
      );
    };
  };
}
