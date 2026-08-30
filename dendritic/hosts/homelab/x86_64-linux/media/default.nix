{inputs, ...}: {
  flake.nixosModules.media = {
    config,
    pkgs,
    ...
  }: {
    imports = with inputs.self.nixosModules; [
      # keep-sorted start
      boot-efi
      boot-loader-grub
      boot-serial-console
      cpu-intel
      disko-impermanence
      hardware-defaults
      network-dns
      network-firewall
      network-interfaces
      service-bazarr
      service-jellyfin
      service-komga
      service-prowlarr
      service-qbittorrent
      service-radarr
      service-sonarr
      service-ssh
      settings-locale
      settings-nix
      software-sudo
      system-impermanence
      # keep-sorted end
    ];

    disko.devices.disk.main.device = "/dev/sda";

    # Proxmox VM, not real Intel hardware -- no RAPL sysfs for thermald to
    # read, so it exits immediately every boot instead of doing anything.
    services.thermald.enable = false;

    age.secrets."smb-creds".file = ./.smb/smb.creds.age;

    environment.systemPackages = with pkgs; [cifs-utils];

    fileSystems = builtins.listToAttrs (
      builtins.map
      (share: {
        name = "/mnt/${share}";
        value = {
          device = "//192.168.1.3/${share}";
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
      })
      [
        "backups"
        "media"
      ]
    );

    networking = {
      hostName = "media";
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
    };

    system.stateVersion = "26.11";

    users.users.media = {
      initialPassword = "media";
      isNormalUser = true;
      extraGroups = ["wheel" "sshusers"];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP9RzisL6wVQK3scDyEPEpFgrcdFYkW9LssnWlORGXof"
      ];
    };
  };

  flake.nixosConfigurations = inputs.self.lib.mkNixos "x86_64-linux" "media";
}
