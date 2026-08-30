{inputs, ...}: {
  flake.nixosModules.router = {config, ...}: let
    domain = "kike.wtf";
  in {
    imports =
      [inputs.disko.nixosModules.default]
      ++ (with inputs.self.nixosModules; [
        # keep-sorted start
        boot-serial-console
        cpu-intel
        hardware-defaults
        network-dns
        network-forwarding
        network-interfaces
        network-nftables
        service-headscale
        service-ssh
        settings-locale
        settings-nix
        software-network-tools
        software-sudo
        software-tailscale
        system-impermanence
        # keep-sorted end
      ]);

    # Encrypted for this host's own SSH host key (plus pumita, so secrets can
    # still be edited from the admin machine) -- agenix's default
    # age.identityPaths already resolves to services.openssh.hostKeys, and
    # /etc/ssh is persisted by system-impermanence, so no extra wiring is
    # needed for the router to decrypt these itself at activation.
    age.secrets = {
      "cloudflare-key".file = ./.ddclient/cloudflare-key.age;
      "tailscale-preauth-key".file = ./.tailscale/preauth-key.age;
    };

    # WAN-facing sysctls only: don't act on router-advertised IPv6 config
    # from upstream, and don't run SLAAC/temp-address autoconf on eth0.
    boot.kernel.sysctl = {
      "net.ipv6.conf.all.accept_ra" = 0;
      "net.ipv6.conf.all.autoconf" = 0;
      "net.ipv6.conf.all.use_tempaddr" = 0;
      "net.ipv6.conf.eth0.accept_ra" = 2;
      "net.ipv6.conf.eth0.autoconf" = 1;
    };

    # Matches this VM's actual, already-formatted disk exactly (verified via
    # `lsblk -o PARTLABEL,MOUNTPOINT` on the live box) -- this is legacy
    # BIOS/GPT from before disko-impermanence's ESP+nix layout existed, and
    # nixos-rebuild switch never reformats, so the partition names/sizes
    # below have to describe reality, not the newer convention.
    #
    # No boot-loader-grub import: disko itself already sets
    # boot.loader.grub.devices once it sees the EF02 (BIOS-boot) partition
    # below, and adding boot-loader-grub's own `device` on top of that
    # duplicates the entry, which grub's own assertions reject.
    disko.devices = {
      disk.main = {
        type = "disk";
        device = "/dev/sda";
        content = {
          type = "gpt";
          partitions = {
            BOOT = {
              size = "1M";
              type = "EF02";
            };
            BOOT_FS = {
              size = "1G";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/boot";
              };
            };
            NIXOS = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/nix";
                extraArgs = ["-L" "NIXOS"];
              };
            };
          };
        };
      };
      nodev."/" = {
        fsType = "tmpfs";
        mountOptions = ["x-initrd.mount" "defaults" "size=2G" "mode=755"];
      };
    };

    networking = {
      hostName = "router";
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
      nftables.ruleset = builtins.readFile ./.nftables/tables.nft;
    };

    nixpkgs.config.allowUnfree = false;

    services = {
      # Proxmox VM, not real Intel hardware -- no RAPL sysfs for thermald to
      # read, so it exits immediately every boot instead of doing anything.
      thermald.enable = false;

      # Trying this alongside the existing WireGuard setup, not replacing it
      # yet -- reuses the same domain ddclient already keeps pointed at this
      # box, just on a different port.
      headscale.settings = {
        server_url = "https://vpn.${domain}";
        tls_letsencrypt_hostname = "vpn.${domain}";
        policy = {
          mode = "file";
          path = ./.headscale/acl.hujson;
        };
        dns = {
          magic_dns = true;
          base_domain = "me.${domain}";
          search_domains = [
            "me.${domain}"
            "home.${domain}"
            "game.${domain}"
            "media.${domain}"
          ];
          extra_records = [
            # Homelab (.home.kike.wtf)
            {
              name = "router.home.${domain}";
              type = "A";
              value = "100.64.0.1";
            }
            {
              name = "router.home.${domain}";
              type = "AAAA";
              value = "fd7a:115c:a1e0::1";
            }
            {
              name = "nas.home.${domain}";
              type = "A";
              value = "192.168.1.3";
            }
            {
              name = "proxmox.home.${domain}";
              type = "A";
              value = "192.168.1.4";
            }
            {
              name = "media.home.${domain}";
              type = "A";
              value = "10.0.10.3";
            }

            # Gaming (.game.kike.wtf)
            {
              name = "wow.game.${domain}";
              type = "A";
              value = "10.0.10.10";
            }

            # Media (.media.kike.wtf)
            {
              name = "jellyfin.media.${domain}";
              type = "A";
              value = "10.0.10.3";
            }
          ];
        };
      };

      # Subnet router only: gaming/services/etc. don't run tailscale
      # themselves, they're just reachable through the LAN route this
      # advertises. `headscale routes enable` still has to approve it once
      # the node registers, same as approving a new node.
      tailscale = {
        authKeyFile = config.age.secrets."tailscale-preauth-key".path;
        useRoutingFeatures = "server";
        extraUpFlags = [
          "--login-server=https://vpn.${domain}"
          "--advertise-routes=10.0.10.0/24,192.168.1.3/32,192.168.1.4/32"
        ];
      };

      ddclient = {
        enable = true;
        domains = ["vpn.${domain}"];
        interval = "1h";
        protocol = "cloudflare";
        passwordFile = config.age.secrets."cloudflare-key".path;
        verbose = true;
        zone = domain;
      };

      dnsmasq = {
        enable = true;
        resolveLocalQueries = false;
        settings = {
          # More specific entries win over the wildcard: LAN/tailnet clients
          # get sent straight to the router over the LAN instead of round-
          # tripping out to the internet and back for its own public IP
          # (which may not even hairpin back in on every ISP router anyway).
          address = [
            "/${domain}/10.0.10.1"
            "/vpn.${domain}/10.0.10.254"
          ];
          bind-dynamic = true;
          interface = [
            "vl10.homelab"
            "vl20.hacking"
          ];
          dhcp-range = [
            "vl10.homelab,10.0.10.100,10.0.10.200,255.255.255.0,24h"
            "vl20.hacking,10.0.20.100,10.0.20.200,255.255.255.0,24h"
          ];
          dhcp-option = [
            "vl10.homelab,option:router,${(builtins.head config.networking.interfaces."vl10.homelab".ipv4.addresses).address}"
            "vl10.homelab,option:dns-server,${(builtins.head config.networking.interfaces."vl10.homelab".ipv4.addresses).address}"
            "vl20.hacking,option:router,${(builtins.head config.networking.interfaces."vl20.hacking".ipv4.addresses).address}"
            "vl20.hacking,option:dns-server,${(builtins.head config.networking.interfaces."vl20.hacking".ipv4.addresses).address}"
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
    };

    system.stateVersion = "26.11";

    users.users.router = {
      initialPassword = "router";
      isNormalUser = true;
      extraGroups = ["wheel" "sshusers"];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP9RzisL6wVQK3scDyEPEpFgrcdFYkW9LssnWlORGXof"
      ];
    };
  };

  flake.nixosConfigurations = inputs.self.lib.mkNixos "x86_64-linux" "router";
}
