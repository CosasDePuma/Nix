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
  # ┃                Environment                ┃
  # ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

  environment.systemPackages = with pkgs; [
    cifs-utils
  ];

  # ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  # ┃                FileSystems                ┃
  # ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

  fileSystems = {
    "/mnt/backups" = {
      device = "//192.168.1.3/backups";
      fsType = "cifs";
      options = [
        "credentials=${config.age.secrets."samba.creds".path}"
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
    secrets = {
      "samba.creds".file = ./samba.creds.age;
    };
  };

  # ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  # ┃               Inputs: Disko               ┃
  # ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

  disko.devices = {
    disk = {
      "disk0" = {
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
    };
    nodev."/tmp".fsType = "tmpfs";
  };

  # ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  # ┃                Networking                 ┃
  # ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

  networking = {
    # --- host
    hostName = "wow";
    hostId = builtins.substring 0 8 (builtins.hashString "md5" config.networking.hostName);
    # --- interfaces
    usePredictableInterfaceNames = false;
    interfaces = {
      # --- physical interfaces
      "eth0" = {
        useDHCP = false;
        ipv4.addresses = [
          {
            address = "10.0.20.2";
            prefixLength = 24;
          }
        ];
      };
    };
    # --- gateway
    defaultGateway = {
      interface = "eth0";
      address = "10.0.20.254";
    };
    # --- dns
    domain = "home";
    search = [ "home" ];
    nameservers = [ "10.0.20.254" ];
    # --- firewall
    firewall = {
      enable = true;
      allowedTCPPorts = [
        64022 # SSH
      ];
    };
  };

  # ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  # ┃                    Nix                    ┃
  # ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
      persistent = true;
    };
    settings.allowed-users = [ "@wheel" ];
  };

  # ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  # ┃                  Nixpkgs                  ┃
  # ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

  nixpkgs.config.allowUnfree = true;

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
    # │                OpenSSH               │
    # └──────────────────────────────────────┘

    openssh = {
      enable = true;
      allowSFTP = true;
      authorizedKeysInHomedir = false;
      listenAddresses = [
        {
          addr = "0.0.0.0";
          port = 64022;
        }
      ];
      ports = [ ];
      startWhenNeeded = true;
      banner = ''
        ==============================================================
        |                   AUTHORIZED ACCESS ONLY                   |
        ==============================================================
        |                                                            |
        |    WARNING: All connections are monitored and recorded.    |
        |  Disconnect IMMEDIATELY if you are not an authorized user! |
        |                                                            |
        |       *** Unauthorized access will be prosecuted ***       |
        |                                                            |
        ==============================================================
      '';
      settings = {
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
        AllowUsers = lib.attrsets.mapAttrsToList (name: _: name) (
          lib.attrsets.filterAttrs (_: v: builtins.elem "sshuser" v.extraGroups) config.users.users
        );
      };
    };
  };

  # ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  # ┃                  System                   ┃
  # ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

  system = {
    inherit stateVersion;

    autoUpgrade = {
      enable = true;
      flake = "github:cosasdepuma/nix";
      dates = "daily";
      operation = "switch";
      persistent = true;
    };

    activationScripts = {
      "oci-containers-networks".text =
        let
          inherit (config.virtualisation.oci-containers) backend;
        in
        ''
          #!${pkgs.runtimeShell}
          # Create the OCI containers networks
          ${pkgs."${backend}"}/bin/${backend} network inspect public 2>&1 >/dev/null || \
          ${pkgs."${backend}"}/bin/${backend} network create --subnet=10.200.0.0/24 public
        '';
      "habbo-repository".text = ''
        #!${pkgs.runtimeShell}
        # Create the OCI containers networks
        ${pkgs.coreutils}/bin/test -d /srv/havana || \
          ${pkgs.git}/bin/git clone --depth=1 https://github.com/habboservers/docker-habbo-server /srv
      '';
    };
  };

  # ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  # ┃                  Timezone                 ┃
  # ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

  time.timeZone = "Europe/Madrid";

  # ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  # ┃                   Users                   ┃
  # ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

  users = {
    mutableUsers = false;
    # --- groups
    groups = {
      "sshuser" = { };
      "users" = { };
    };
    # --- users
    users."wow" = {
      isNormalUser = true;
      description = "World of Warcraft management user";
      initialPassword = null;
      home = "/home/users/wow";
      uid = 1000;
      group = "users";
      useDefaultShell = true;
      extraGroups = [
        "docker"
        "sshuser"
        "wheel"
      ];
      openssh.authorizedKeys.keys = lib.strings.splitString "\n" (builtins.readFile ./authorized_keys);
    };
  };

  # ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  # ┃               Virtualisation              ┃
  # ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

  virtualisation = {
    docker = {
      enable = true;
      autoPrune = {
        enable = true;
        dates = "daily";
        persistent = true;
        flags = [
          "--all"
          "--force"
          "--volumes"
        ];
      };
    };

    oci-containers = {
      backend = "docker";
      containers = {
        #  "database" = {
        #    hostname = "database";
        #    image = "mysql:8.4";
        #    networks = [ "public" ];
        #    environment = {
        #      MYSQL_ROOT_PASSWORD = "password";
        #    };
        #    volumes = [
        #      "database:/var/lib/mysql"
        #    ];
        #  };
        #  "client-azerothcore" = {
        #    hostname = "client-azerothcore";
        #    image = "acore/ac-wotlk-client-data:master";
        #    volumes = [
        #      "azerothcore-data:/azerothcore/env/dist/data"
        #    ];
        #  };
        #  "database-azerothcore" = {
        #    hostname = "database-azerothcore";
        #    image = "acore/ac-wotlk-db-import:master";
        #    networks = [ "public" ];
        #    environment = {
        #      AC_DATA_DIR = "/azerothcore/env/dist/data";
        #      AC_LOGS_DIR = "/azerothcore/env/dist/logs";
        #      AC_LOGIN_DATABASE_INFO = "database;3306;root;password;acore_auth";
        #      AC_WORLD_DATABASE_INFO = "database;3306;root;password;acore_world";
        #      AC_CHARACTER_DATABASE_INFO = "database;3306;root;password;acore_characters";
        #    };
        #    volumes = [
        #      "azerothcore-env:/azerothcore/env/dist/etc"
        #      "azerothcore-logs:/azerothcore/env/dist/logs:delegated"
        #    ];
        #    dependsOn = [
        #      "database"
        #    ];
        #  };
        #  "auth-azerothcore" = {
        #    hostname = "auth-azerothcore";
        #    image = "acore/ac-wotlk-authserver:master";
        #    networks = [ "public" ];
        #    ports = [
        #      "0.0.0.0:3724:3724"
        #    ];
        #    environment = {
        #      USER_CONF_PATH = "/azerothcore/apps/docker/config-docker.sh";
        #      DATAPATH = "/azerothcore/env/dist/data";
        #      CTYPE = "RelWithDebInfo";
        #      CSCRIPTS = "static";
        #      AC_CCACHE = "true";
        #      AC_DATA_DIR = "/azerothcore/env/dist/data";
        #      AC_LOGS_DIR = "/azerothcore/env/dist/logs";
        #      AC_TEMP_DIR = "/azerothcore/env/dist/temp";
        #      AC_LOGIN_DATABASE_INFO = "database;3306;root;password;acore_auth";
        #    };
        #    volumes = [
        #      "azerothcore-env:/azerothcore/env/dist/etc"
        #      "azerothcore-logs:/azerothcore/env/dist/logs:delegated"
        #    ];
        #    dependsOn = [
        #      "database"
        #    ];
        #  };
        #  "world-azerothcore" = {
        #    hostname = "world-azerothcore";
        #    image = "acore/ac-wotlk-worldserver:master";
        #    networks = [ "public" ];
        #    ports = [
        #      "0.0.0.0:7878:7878"
        #      "0.0.0.0:8085:8085"
        #    ];
        #    environment = {
        #      USER_CONF_PATH = "/azerothcore/apps/docker/config-docker.sh";
        #      DATAPATH = "/azerothcore/env/dist/data";
        #      CTYPE = "RelWithDebInfo";
        #      CSCRIPTS = "static";
        #      AC_CCACHE = "true";
        #      AC_DATA_DIR = "/azerothcore/env/dist/data";
        #      AC_LOGS_DIR = "/azerothcore/env/dist/logs";
        #      AC_LOGIN_DATABASE_INFO = "database;3306;root;password;acore_auth";
        #      AC_WORLD_DATABASE_INFO = "database;3306;root;password;acore_world";
        #      AC_CHARACTER_DATABASE_INFO = "database;3306;root;password;acore_characters";
        #    };
        #    volumes = [
        #      "azerothcore-env:/azerothcore/env/dist/etc"
        #      "azerothcore-logs:/azerothcore/env/dist/logs:delegated"
        #      "azerothcore-data:/azerothcore/env/dist/data:ro"
        #    ];
        #    dependsOn = [
        #      "client-azerothcore"
        #      "database"
        #    ];
        #  };
        #};
        "habbo" = {
          hostname = "habbo";
          image = "vitorvasc/docker-habbo-server:latest";
          environment = {
            HABBO_SERVER_IP_BIND = "0.0.0.0";
            HABBO_WEBSERVER_IP_BIND = "0.0.0.0";
            HABBO_DATABASE_HOST = "database";
            HABBO_DATABASE_PORT = "3306";
            HABBO_DATABASE_USERNAME = "havana";
            HABBO_DATABASE_PASSWORD = "havana";
            HABBO_DATABASE_NAME = "havana";
            HABBO_WEBSERVER_STATIC_CONTENT_PATH = "https://cdn.habboservers.com/havana";
            HABBO_WEBSERVER_SITE_PATH = "http://localhost";
          };
          ports = [
            "0.0.0.0:80:80"
            "0.0.0.0:12321:12321"
          ];
          networks = [ "public" ];
          dependsOn = [
            "database"
          ];
        };
        "database" = {
          hostname = "database";
          image = "mariadb:10.3.9";
          environment = {
            MYSQL_ROOT_PASSWORD = "pass";
            MYSQL_DATABASE = "havana";
            MYSQL_USER = "havana";
            MYSQL_PASSWORD = "havana";
          };
          networks = [ "public" ];
          volumes = [
            "/srv/examples/havana/havana-mariadb-example/database:/docker-entrypoint-initdb.d"
            "habbo:/var/lib/mysql"
          ];
        };
      };
    };
  };
}
