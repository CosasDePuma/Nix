{inputs, ...}: {
  flake.nixosModules.gaming = {
    config,
    lib,
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
      # wow.game.kike.wtf doesn't actually resolve -- checked both from
      # this host (using its own /etc/resolv.conf, public 1.1.1.1/8.8.8.8)
      # and from inside a container, neither works. It was presumably meant
      # to go through the router's own DNS (headscale/magic DNS), which
      # this host isn't configured to use. Found the hard way: authserver's
      # first genuine cold start refused to list the realm at all
      # ("Could not resolve address wow.game.kike.wtf"). Use the host's own
      # real interface address instead -- pulled from the same networking
      # config above rather than a second hardcoded literal that could
      # drift from it.
      REALM_ADDRESS = (lib.head config.networking.interfaces.eth0.ipv4.addresses).address;
      REALM_NAME = "Isekai of Warcraft";
    };

    virtualisation.oci-containers.containers."isekaiofwarcraft-worldserver".environment.AC_MOTD = "Welcome to Isekai of Warcraft! 5x XP, 2x drop, hardcore 1-79.";

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
