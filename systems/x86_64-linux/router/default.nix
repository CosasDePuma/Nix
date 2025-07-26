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
      "tailscale-preauth.key".file = ./tailscale-preauth.key.age;
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
      "vl10.corp".ipv4.addresses = [
        {
          address = "10.0.10.254";
          prefixLength = 24;
        }
      ];
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
    # --- vlans
    vlans = {
      "vl10.corp" = {
        id = 10;
        interface = "eth1";
      };
      "vl20.redteam" = {
        id = 20;
        interface = "eth1";
      };
      "vl255.dmz" = {
        id = 255;
        interface = "eth1";
      };
    };
    # --- gateway
    defaultGateway = {
      interface = "eth0";
      address = "172.16.0.1";
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
          "vl10.corp"
          "vl20.redteam"
          "vl255.dmz"
        ];
        dhcp-range = [
          "vl10.corp,10.0.10.100,10.0.10.200,255.255.255.0,24h"
          "vl20.redteam,10.0.20.100,10.0.20.200,255.255.255.0,24h"
          "vl255.dmz,10.0.255.100,10.0.255.200,255.255.255.0,24h"
        ];
        dhcp-option = [
          "vl10.corp,option:router,${
            (builtins.head config.networking.interfaces."vl10.corp".ipv4.addresses).address
          }"
          "vl10.corp,option:dns-server,${
            (builtins.head config.networking.interfaces."vl10.corp".ipv4.addresses).address
          }"
          "vl10.corp,option:domain-name,audea.corp"
          "vl10.corp,option:domain-search,audea.corp"
          "vl20.redteam,option:router,${
            (builtins.head config.networking.interfaces."vl20.redteam".ipv4.addresses).address
          }"
          "vl20.redteam,option:dns-server,${
            (builtins.head config.networking.interfaces."vl20.redteam".ipv4.addresses).address
          }"
          "vl20.redteam,option:domain-name,audea.corp"
          "vl20.redteam,option:domain-search,audea.corp"
          "vl255.dmz,option:router,${
            (builtins.head config.networking.interfaces."vl255.dmz".ipv4.addresses).address
          }"
          "vl255.dmz,option:dns-server,${
            (builtins.head config.networking.interfaces."vl255.dmz".ipv4.addresses).address
          }"
          "vl255.dmz,option:domain-name,audea.corp"
          "vl255.dmz,option:domain-search,audea.corp"
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
    # │               Headscale              │
    # └──────────────────────────────────────┘

    headscale = {
      enable = true;
      address = "127.0.0.1";
      port = 8080;
      settings = {
        server_url = "http://mesh.audea.com";
        dns = {
          base_domain = "audea.corp";
          search_domains = [ "audea.corp" ];
          nameservers.global = [ "1.1.1.1" ];
        };
        logtail.enable = false;
      };
    };
    tailscale = {
      enable = true;
      authKeyFile = config.age.secrets."tailscale-preauth.key".path;
      authKeyParameters.baseURL = "http://127.0.0.1:8080";
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
