{inputs, ...}: {
  # A microVM rather than a container: AzerothCore runs on Podman, and
  # nesting it inside systemd-nspawn is fragile.
  flake.nixosModules.monolab-gaming = {
    microvm.vms.gaming.config = {
      config,
      lib,
      ...
    }: {
      imports = with inputs.self.nixosModules; [
        # keep-sorted start
        network-dns
        network-firewall
        service-azerothcore
        service-ssh
        settings-locale
        settings-nix
        software-sudo
        system-microvm
        # keep-sorted end
      ];

      microvm = {
        vcpu = 4;
        mem = 8192;
        interfaces = [
          {
            type = "tap";
            id = "vm-gaming";
            mac = "02:00:00:0a:00:0a";
          }
        ];
        volumes = [
          {
            image = "persist.img";
            mountPoint = "/nix/persist";
            size = 65536;
          }
        ];
      };

      networking = {
        hostName = "gaming";
        interfaces.eth0.ipv4.addresses = [
          {
            address = "10.0.10.10";
            prefixLength = 24;
          }
        ];
        defaultGateway = {
          interface = "eth0";
          address = "10.0.10.254";
        };
      };

      systemd.services."ac-realmlist-config".environment = {
        REALM_ADDRESS = (lib.head config.networking.interfaces.eth0.ipv4.addresses).address;
        REALM_NAME = "Isekai of Warcraft";
      };

      users.users.gamer = {
        initialPassword = "gamer";
        isNormalUser = true;
        extraGroups = ["wheel" "sshusers"];
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP9RzisL6wVQK3scDyEPEpFgrcdFYkW9LssnWlORGXof"
        ];
      };

      virtualisation.oci-containers.containers."isekaiofwarcraft-worldserver".environment.AC_MOTD = "Welcome to Isekai of Warcraft! 5x XP, 2x drop, random speels and hardcore 1-79.";
    };
  };
}
