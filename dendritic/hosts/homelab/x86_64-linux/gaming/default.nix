{inputs, ...}: {
  flake.nixosModules.gaming = {
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
      service-azerothcore
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

    networking = {
      hostName = "gaming";
      interfaces."eth0" = {
        useDHCP = false;
        ipv4.addresses = [
          {
            address = "10.0.10.10";
            prefixLength = 24;
          }
        ];
      };
      defaultGateway = {
        interface = "eth0";
        address = "10.0.10.254";
      };
    };

    systemd.services."ac-realmlist-config".environment = {
      REALM_ADDRESS = "wow.game.kike.wtf";
      REALM_NAME = "Isekai of Warcraft";
    };

    virtualisation.oci-containers.containers.ac-worldserver.environment.AC_MOTD =
      "Welcome to Isekai of Warcraft! 5x XP, 2x drop, hardcore 1-79.";

    system.stateVersion = "26.11";

    users.users.gamer = {
      initialPassword = "gamer";
      isNormalUser = true;
      extraGroups = ["wheel" "sshusers"];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP9RzisL6wVQK3scDyEPEpFgrcdFYkW9LssnWlORGXof"
      ];
    };
  };

  flake.nixosConfigurations = inputs.self.lib.mkNixos "x86_64-linux" "gaming";
}
