{inputs, ...}: {
  flake.nixosModules.agents = {
    imports = with inputs.self.nixosModules; [
      # keep-sorted start
      boot-efi
      boot-loader-grub
      cpu-intel
      disko-impermanence
      hardware-defaults
      hardware-serial
      network-dns
      network-firewall
      network-interfaces
      service-rakazo
      service-ssh
      settings-locale
      settings-nix
      software-sudo
      system-impermanence
      # keep-sorted end
    ];

    disko.devices.disk.main.device = "/dev/sda";

    networking = {
      hostName = "agents";
      interfaces."eth0" = {
        useDHCP = false;
        ipv4.addresses = [
          {
            address = "10.0.10.20";
            prefixLength = 24;
          }
        ];
      };
      defaultGateway = {
        interface = "eth0";
        address = "10.0.10.254";
      };
    };

    services.thermald.enable = false;

    users.users.agents = {
      initialPassword = "agents";
      isNormalUser = true;
      extraGroups = ["wheel" "sshusers"];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP9RzisL6wVQK3scDyEPEpFgrcdFYkW9LssnWlORGXof"
      ];
    };

    virtualisation.oci-containers.containers.rakazo-web.environment.RAKAZO_HOST = "agents.kike.wtf";
  };

  flake.nixosConfigurations = inputs.self.lib.mkNixos "x86_64-linux" "agents";
}
