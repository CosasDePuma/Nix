{inputs, ...}: {
  # A microVM, never a container: Paperclip's agents run LLM-generated code
  # with their CLIs' full tool access, so they get their own kernel.
  flake.nixosModules.homelab-agents = {
    microvm.vms.agents.config = {
      imports = with inputs.self.nixosModules; [
        # keep-sorted start
        network-dns
        network-firewall
        service-paperclip
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
            id = "vm-agents";
            mac = "02:00:00:0a:00:04";
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
        hostName = "agents";
        interfaces.eth0.ipv4.addresses = [
          {
            address = "10.0.10.4";
            prefixLength = 24;
          }
        ];
        defaultGateway = {
          interface = "eth0";
          address = "10.0.10.254";
        };
        # The router's dnsmasq answers *.kike.wtf with Caddy, so agent runs
        # can reach Paperclip's own public URL (public DNS doesn't know it).
        nameservers = ["10.0.10.254"];
      };

      users.users.agents = {
        initialPassword = "agents";
        isNormalUser = true;
        extraGroups = ["wheel" "sshusers"];
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP9RzisL6wVQK3scDyEPEpFgrcdFYkW9LssnWlORGXof"
        ];
      };

      virtualisation.oci-containers.containers.paperclip.environment = {
        PAPERCLIP_PUBLIC_URL = "https://agents.kike.wtf";
        # Homepage's siteMonitor probes the VM directly.
        PAPERCLIP_ALLOWED_HOSTNAMES = "10.0.10.4";
      };
    };
  };
}
