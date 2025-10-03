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

  boot = {
    # --- loader
    loader.grub.enable = true;
    # --- kernel
    kernel.sysctl = {
      "net.ipv4.conf.all.forwarding" = true;
      "net.ipv6.conf.all.forwarding" = true;
      "net.ipv6.conf.all.accept_ra" = 0;
      "net.ipv6.conf.all.autoconf" = 0;
      "net.ipv6.conf.all.use_tempaddr" = 0;
      "net.ipv6.conf.eth0.accept_ra" = 2;
      "net.ipv6.conf.eth0.autoconf" = 1;
    };
    # --- nix store
    readOnlyNixStore = true;
  };

  # ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  # ┃                Environment                ┃
  # ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

  environment.systemPackages = with pkgs; [
    dig
    tcpdump
  ];

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
      "wireguard.key".file = ./wireguard.key.age;
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
    nodev = {
      "/tmp" = {
        fsType = "tmpfs";
        mountOptions = [
          "noexec"
          "size=1G"
        ];
      };
    };
  };

  # ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  # ┃                Networking                 ┃
  # ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

  networking = {
    # --- host
    hostName = "router";
    hostId = builtins.substring 0 8 (builtins.hashString "md5" config.networking.hostName);
    # --- interfaces
    usePredictableInterfaceNames = false;
    interfaces = {
      # --- physical interfaces
      "eth0" = {
        useDHCP = false;
        ipv4.addresses = [
          {
            address = "172.16.0.2";
            prefixLength = 24;
          }
        ];
      };
      "eth1".useDHCP = false;
      # --- virtual interfaces
      "vl20.redteam".ipv4.addresses = [
        {
          address = "10.0.20.254";
          prefixLength = 24;
        }
      ];
      "vl255.dmz".ipv4.addresses = [
        {
          address = "10.0.255.254";
          prefixLength = 24;
        }
      ];
    };

    # --- gateway
    defaultGateway = {
      interface = "eth0";
      address = "172.16.0.1";
    };
    # --- vlans
    vlans = {
      "vl20.redteam" = {
        id = 20;
        interface = "eth1";
      };
      "vl255.dmz" = {
        id = 255;
        interface = "eth1";
      };
    };
    # --- wireguard
    wireguard = {
      enable = true;
      interfaces."wireguard" = {
        ips = ["10.10.10.254/24"];
        listenPort = 51820;
        privateKeyFile = config.age.secrets."wireguard.key".path;
        peers = let
          users = [
            {
              name = "efontan";
              publicKey = "09SUz/zGOFkZKnV8e8k+MJ4ul97EAvFEm8MN2rjztkQ=";
            }
            {
              name = "jlzayas";
              publicKey = "6BVvYsdL54NFNMMq/KvY1sTIJSnli4keNbAbPWJ1JTg=";
            }
            {
              name = "arecuerda";
              publicKey = "53ryeMG/zQwjiRbt91PYfp2FpHu3CWgJGBvCrFXcajQ=";
            }
            {
              name = "gvega";
              publicKey = "vgk5LopyO0/sRse6NS+0yTCxbseNVEurzj1YVVtGoio=";
            }
            {
              name = "fabiom";
              publicKey = "txqyCEZYJk37bXBNcvsSZ4sjIfKy2vB4nZKKWApBemc=";
            }
          ];
        in lib.lists.imap1 (i: user: {
          inherit (user) name publicKey;
          allowedIPs = ["10.10.10.${builtins.toString i}/32"];
          persistentKeepalive = 25;
        }) users;
      };
    };
    # --- dns
    domain = "audea.corp";
    search = [ "audea.corp" ];
    nameservers = [
      "1.1.1.1"
      "8.8.8.8"
    ];
    # --- firewall
    nat.enable = false;
    firewall.enable = false;
    nftables = {
      enable = true;
      ruleset = builtins.readFile ./tables.nft;
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
    # │                DNSmasq               │
    # └──────────────────────────────────────┘

    dnsmasq = {
      enable = true;
      resolveLocalQueries = false;
      settings = {
        bind-dynamic = true;
        interface = [
          "vl20.redteam"
          "vl255.dmz"
          "wireguard"
        ];
        dhcp-range = [
          "vl20.redteam,10.0.20.100,10.0.20.200,255.255.255.0,24h"
          "vl255.dmz,10.0.255.100,10.0.255.200,255.255.255.0,24h"
        ];
        dhcp-option = [
          "vl20.redteam,option:router,${
            (builtins.head config.networking.interfaces."vl20.redteam".ipv4.addresses).address
          }"
          "vl20.redteam,option:dns-server,${
            (builtins.head config.networking.interfaces."vl20.redteam".ipv4.addresses).address
          }"
          "vl255.dmz,option:router,${
            (builtins.head config.networking.interfaces."vl255.dmz".ipv4.addresses).address
          }"
          "vl255.dmz,option:dns-server,${
            (builtins.head config.networking.interfaces."vl255.dmz".ipv4.addresses).address
          }"
          "wireguard,option:router,${
            builtins.head (lib.strings.splitString "/" (builtins.head (config.networking.wireguard.interfaces."wireguard".ips)))
          }"
          "wireguard,option:dns-server,${
            builtins.head (lib.strings.splitString "/" (builtins.head (config.networking.wireguard.interfaces."wireguard".ips)))
          }"
        ];
        cache-size = 1000;
        domain-needed = true;
        bogus-priv = true;
        no-hosts = true;
        no-resolv = true;
        no-poll = true;
        server = [
          "1.1.1.1"
          "8.8.8.8"
        ];
      };
    };

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
      enable = false; # FIXME(git): Enable this when we have a proper upgrade strategy.
      flake = "github:cosasdepuma/nix/audea";
      dates = "daily";
      operation = "switch";
      persistent = true;
    };
  };

  # ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  # ┃                  Timezone                 ┃
  # ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

  time.timeZone = "Europe/Madrid";

  # ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  # ┃                  Users                    ┃
  # ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

  users = {
    mutableUsers = false;
    # --- groups
    groups = {
      "sshuser" = { };
      "users" = { };
    };
    # --- users
    users."router" = {
      isNormalUser = true;
      description = "Router management user";
      initialPassword = null;
      home = "/home/users/router";
      uid = 1000;
      group = "users";
      useDefaultShell = true;
      extraGroups = [
        "wheel"
        "sshuser"
      ];
      openssh.authorizedKeys.keys = lib.strings.splitString "\n" (builtins.readFile ./authorized_keys);
    };
  };
}
