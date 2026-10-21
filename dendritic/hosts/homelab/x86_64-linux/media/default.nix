{inputs, ...}: {
  # A microVM rather than a container: CIFS mounts need their own kernel.
  flake.nixosModules.homelab-media = {
    microvm.vms.media.config = {config, ...}: {
      imports = with inputs.self.nixosModules; [
        # keep-sorted start
        homelab-backups
        network-dns
        network-firewall
        service-jellyfin
        service-komga
        service-qbittorrent
        service-ssh
        settings-locale
        settings-nix
        software-sudo
        system-microvm
        # keep-sorted end
      ];

      microvm = {
        vcpu = 4;
        mem = 4096;
        interfaces = [
          {
            type = "tap";
            id = "vm-media";
            mac = "02:00:00:0a:00:02";
          }
        ];
        volumes = [
          {
            image = "persist.img";
            mountPoint = "/nix/persist";
            size = 32768;
          }
        ];
      };

      # Same NAS credentials homelab-backups brings in for /mnt/backups.
      fileSystems."/mnt/media" = {
        device = "//192.168.1.3/media";
        fsType = "cifs";
        options = [
          "credentials=${config.age.secrets."smb-creds".path}"
          "noauto"
          "x-systemd.automount"
          "x-systemd.device-timeout=5s"
          "x-systemd.idle-timeout=60"
          "x-systemd.mount-timeout=5s"
        ];
      };

      networking = {
        hostName = "media";
        interfaces.eth0.ipv4.addresses = [
          {
            address = "10.0.10.2";
            prefixLength = 24;
          }
        ];
        defaultGateway = {
          interface = "eth0";
          address = "10.0.10.254";
        };
      };

      users.users.media = {
        initialPassword = "media";
        isNormalUser = true;
        extraGroups = ["wheel" "sshusers"];
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP9RzisL6wVQK3scDyEPEpFgrcdFYkW9LssnWlORGXof"
        ];
      };
    };
  };
}
