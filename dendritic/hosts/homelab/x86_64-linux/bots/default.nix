{inputs, ...}: {
  # A microVM, never a container: Rakazo's supervisor holds the Docker
  # socket and runs LLM-generated code, so it gets its own kernel.
  flake.nixosModules.homelab-bots = {
    microvm.vms.bots.config = {
      imports = with inputs.self.nixosModules; [
        # keep-sorted start
        network-dns
        network-firewall
        service-rakazo
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
            id = "vm-bots";
            mac = "02:00:00:0a:00:03";
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
        hostName = "bots";
        interfaces.eth0.ipv4.addresses = [
          {
            address = "10.0.10.3";
            prefixLength = 24;
          }
        ];
        defaultGateway = {
          interface = "eth0";
          address = "10.0.10.254";
        };
      };

      users.users.bots = {
        initialPassword = "bots";
        isNormalUser = true;
        extraGroups = ["wheel" "sshusers"];
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP9RzisL6wVQK3scDyEPEpFgrcdFYkW9LssnWlORGXof"
        ];
      };

      virtualisation.oci-containers.containers.rakazo-web.environment.RAKAZO_HOST = "bots.kike.wtf";
    };
  };
}
