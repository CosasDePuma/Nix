{inputs, ...}: {
  flake.nixosModules.barebone = {
    imports = with inputs.self.nixosModules; [
      inputs.microvm.nixosModules.host
      # keep-sorted start
      boot-efi
      boot-loader-grub
      cpu-intel
      disko-impermanence
      hardware-defaults
      homelab-agents
      homelab-bots
      homelab-media
      homelab-router
      network-dns
      network-firewall
      network-interfaces
      network-wakeonlan
      service-reboot
      service-ssh
      settings-locale
      settings-nix
      software-sudo
      system-impermanence
      # keep-sorted end
    ];

    disko.devices.disk.main.device = "/dev/disk/by-id/ata-CT2000MX500SSD1_2321E6DA4440";

    networking = {
      hostName = "barebone";
      useDHCP = false;
      useNetworkd = true;
    };

    systemd.network = {
      netdevs = {
        "10-br-lan".netdevConfig = {
          Name = "br-lan";
          Kind = "bridge";
        };
        # Internal switch between the router VM and every other VM; no
        # physical port and no host address, VLANs are the only segmentation.
        "10-br-vlans" = {
          netdevConfig = {
            Name = "br-vlans";
            Kind = "bridge";
          };
          bridgeConfig = {
            VLANFiltering = true;
            DefaultPVID = "none";
          };
        };
      };

      networks = {
        "20-lan-ports" = {
          matchConfig.Name = ["eth0" "vm-router-wan"];
          networkConfig.Bridge = "br-lan";
        };
        "20-br-lan" = {
          matchConfig.Name = "br-lan";
          address = ["192.168.1.4/24"];
          gateway = ["192.168.1.1"];
          linkConfig.RequiredForOnline = "routable";
        };
        "20-br-vlans" = {
          matchConfig.Name = "br-vlans";
          networkConfig.LinkLocalAddressing = "no";
          linkConfig.RequiredForOnline = "carrier";
        };
        # Router trunk: tagged homelab (10) and hacking (20).
        "30-vlan-trunk" = {
          matchConfig.Name = "vm-router-lan";
          networkConfig.Bridge = "br-vlans";
          bridgeVLANs = [{VLAN = 10;} {VLAN = 20;}];
        };
        # Every other VM is an untagged access port on the homelab VLAN.
        "30-vlan-homelab" = {
          matchConfig.Name = ["vm-agents" "vm-bots" "vm-media"];
          networkConfig.Bridge = "br-vlans";
          bridgeVLANs = [
            {
              VLAN = 10;
              PVID = 10;
              EgressUntagged = 10;
            }
          ];
        };
      };
    };

    # The host only bridges; routing belongs to the router VM.
    boot.kernel.sysctl."net.ipv4.ip_forward" = 0;

    users.users.barebone = {
      initialPassword = "barebone";
      isNormalUser = true;
      extraGroups = ["wheel" "sshusers"];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP9RzisL6wVQK3scDyEPEpFgrcdFYkW9LssnWlORGXof"
      ];
    };
  };

  flake.nixosConfigurations = inputs.self.lib.mkNixos "x86_64-linux" "barebone";
}
