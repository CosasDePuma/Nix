{ inputs, ... }:
{
  flake.modules.nixos.router =
    { config, pkgs, lib, ... }:
    let
      domain = "kike.wtf";
    in
    {
      imports = with inputs.self.modules.nixos; [
        system-server
        (inputs.self.factory.homelab-user {
          name = "router";
          description = "Router management user";
          home = "/home/users/router";
          authorizedKeysFile = ./.ssh/authorized_keys;
        })
      ];

      age.secrets = {
        "cloudflare.key".file = ./.ddclient/cloudflare.key.age;
        "wireguard.key".file = ./.wireguard/wireguard.key.age;
      };

      boot.kernel.sysctl = {
        "net.ipv4.conf.all.forwarding" = true;
        "net.ipv6.conf.all.forwarding" = true;
        "net.ipv6.conf.all.accept_ra" = 0;
        "net.ipv6.conf.all.autoconf" = 0;
        "net.ipv6.conf.all.use_tempaddr" = 0;
        "net.ipv6.conf.eth0.accept_ra" = 2;
        "net.ipv6.conf.eth0.autoconf" = 1;
      };

      disko.devices.nodev."/tmp".mountOptions = [
        "noexec"
        "size=1G"
      ];

      environment.systemPackages = with pkgs; [
        dig
        iperf
        tcpdump
      ];

      networking = {
        hostName = "router";
        hostId = builtins.substring 0 8 (builtins.hashString "md5" "router");
        usePredictableInterfaceNames = false;
        interfaces = {
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
        defaultGateway = {
          interface = "eth0";
          address = "192.168.1.1";
        };
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
        domain = "home";
        search = [ "home" ];
        nameservers = [
          "1.1.1.1"
          "8.8.8.8"
        ];
        nat.enable = false;
        firewall.enable = false;
        nftables = {
          enable = true;
          ruleset = builtins.readFile ./.nftables/tables.nft;
        };
      };

      nixpkgs.config.allowUnfree = false;

      services = {
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

        openssh.banner = builtins.readFile ./.ssh/banner.txt;
      };

      system.autoUpgrade = {
        enable = true;
        flake = "github:cosasdepuma/nix";
        dates = "daily";
        operation = "switch";
        persistent = true;
      };
    };

  flake.nixosConfigurations = inputs.self.lib.mkNixos "x86_64-linux" "router";
}
