{
  config ? throw "not imported as module",
  lib ? throw "not imported as module",
  pkgs ? throw "not imported as module",
  stateVersion ? "25.05",
  ...
}:
let
  domain = "kike.wtf";
in
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
  };

  # ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  # ┃                Environment                ┃
  # ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

  environment.systemPackages = with pkgs; [
    dig
    iperf
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
      "cloudflare.key".file = ./.ddclient/cloudflare.key.age;
      "wireguard.key".file = ./.wireguard/wireguard.key.age;
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
            address = "192.168.1.254";
            prefixLength = 24;
          }
        ];
      };
      "eth1".useDHCP = false;
      # --- virtual interfaces
      "vl10.homelab".ipv4.addresses = [
        {
          address = "10.0.10.254";
          prefixLength = 24;
        }
      ];
      "vl20.hacking".ipv4.addresses = [
        {
          address = "10.0.20.254";
          prefixLength = 24;
        }
      ];
    };
    # --- gateway
    defaultGateway = {
      interface = "eth0";
      address = "192.168.1.1";
    };
    # --- vlans
    vlans = {
      "vl10.homelab" = {
        id = 10;
        interface = "eth1";
      };
      "vl20.hacking" = {
        id = 20;
        interface = "eth1";
      };
    };
    # --- wireguard
    wireguard = {
      enable = true;
      interfaces."wireguard" = {
        ips = [ "10.10.10.254/24" ];
        listenPort = 51820;
        privateKeyFile = config.age.secrets."wireguard.key".path;
        peers =
          let
            users = [
              {
                name = "pumita-macbook";
                publicKey = "09SUz/zGOFkZKnV8e8k+MJ4ul97EAvFEm8MN2rjztkQ=";
              }
              {
                name = "pumita-iphone";
                publicKey = "fLlRUveH+pYk6efVANQh+g3MJXMvG3rAsY4Z1aAff20=";
              }
              {
                name = "pumita-tv";
                publicKey = "gL2M1YR+FjO9Wq5DjIBcBOtcxw/eyvo6HGv17Q43o2g=";
              }
              {
                name = "family-tv";
                publicKey = "ByqsQxP2YMKzYob5S0Uq9m8+jORNxcaZAApcSc5oQy0=";
              }
              {
                name = "family-david";
                publicKey = "ojqm9Pk4bWfAkoIwvEXRKf+bmxrra1C81HHxltsUhEU=";
              }
              {
                name = "friends-dmaestro";
                publicKey = "7+/GGKXRfKcYGSu/Faj+c5PoEGIdck2VLFUk8IuFE0E=";
              }
            ];
          in
          lib.lists.imap1 (i: user: {
            inherit (user) name publicKey;
            allowedIPs = [ "10.10.10.${builtins.toString i}/32" ];
            persistentKeepalive = 25;
          }) users;
      };
    };
    # --- dns
    domain = "home";
    search = [ "home" ];
    nameservers = [
      "1.1.1.1"
      "8.8.8.8"
    ];
    # --- firewall
    nat.enable = false;
    firewall.enable = false;
    nftables = {
      enable = true;
      ruleset = builtins.readFile ./.nftables/tables.nft;
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
    # │               DDClient               │
    # └──────────────────────────────────────┘

    ddclient = {
      enable = true;
      domains = [
        "vpn.${domain}"
        "minecraft.${domain}"
      ];
      interval = "1h";
      protocol = "cloudflare";
      passwordFile = config.age.secrets."cloudflare.key".path;
      verbose = true;
      zone = domain;
    };

    # ┌──────────────────────────────────────┐
    # │                DNSmasq               │
    # └──────────────────────────────────────┘

    dnsmasq = {
      enable = true;
      resolveLocalQueries = false;
      settings = {
        address = [ "/${domain}/10.0.10.1" ];
        bind-dynamic = true;
        interface = [
          "vl10.homelab"
          "vl20.hacking"
          "wireguard"
        ];
        dhcp-range = [
          "vl10.homelab,10.0.10.100,10.0.10.200,255.255.255.0,24h"
          "vl20.hacking,10.0.20.100,10.0.20.200,255.255.255.0,24h"
        ];
        dhcp-option = [
          "vl10.homelab,option:router,${
            (builtins.head config.networking.interfaces."vl10.homelab".ipv4.addresses).address
          }"
          "vl10.homelab,option:dns-server,${
            (builtins.head config.networking.interfaces."vl10.homelab".ipv4.addresses).address
          }"
          "vl20.hacking,option:router,${
            (builtins.head config.networking.interfaces."vl20.hacking".ipv4.addresses).address
          }"
          "vl20.hacking,option:dns-server,${
            (builtins.head config.networking.interfaces."vl20.hacking".ipv4.addresses).address
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
      banner = builtins.readFile ./.ssh/banner.txt;
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
      openssh.authorizedKeys.keys = lib.strings.splitString "\n" (
        builtins.readFile ./.ssh/authorized_keys
      );
    };
  };
}
