{inputs, ...}: {
  flake.nixosModules.services = {
    config,
    pkgs,
    ...
  }: let
    domain = "kike.wtf";
  in {
    imports = with inputs.self.nixosModules; [
      server-defaults
      service-caddy
      service-homepage
      service-n8n
      service-podman
      (inputs.self.factory.homelab-user {
        name = "services";
        description = "Services management user";
        home = "/home/users/services";
        authorizedKeysFile = ./.ssh/authorized_keys;
      })
    ];

    age.secrets = {
      "acme.env".file = ./.acme/acme.env.age;
      "homepage.env".file = ./.homepage/homepage.env.age;
      "smb.creds".file = ./.smb/smb.creds.age;
    };

    disko.devices.nodev."/tmp".mountOptions = [
      "noexec"
      "size=1G"
    ];

    environment.systemPackages = with pkgs; [
      curl
      openssl
      cifs-utils
      handbrake
    ];

    fileSystems = builtins.listToAttrs (
      builtins.map (share: {
        name = "/mnt/${share}";
        value = {
          device = "//192.168.1.3/${share}";
          fsType = "cifs";
          options = [
            "credentials=${config.age.secrets."smb.creds".path}"
            "noauto"
            "x-systemd.automount"
            "x-systemd.device-timeout=5s"
            "x-systemd.idle-timeout=60"
            "x-systemd.mount-timeout=5s"
          ];
        };
      }) ["backups" "media"]
    );

    networking = {
      hostName = "services";
      hostId = builtins.substring 0 8 (builtins.hashString "md5" "services");
      usePredictableInterfaceNames = false;
      interfaces."eth0" = {
        useDHCP = false;
        ipv4.addresses = [
          {
            address = "10.0.10.1";
            prefixLength = 24;
          }
        ];
      };
      defaultGateway = {
        interface = "eth0";
        address = "10.0.10.254";
      };
      domain = "home";
      search = ["home"];
      nameservers = ["10.0.10.254"];
      firewall = {
        enable = true;
        allowedTCPPorts = [
          443
          5678 # n8n
          25565 # gaming
        ];
      };
    };

    nixpkgs.config.allowUnfree = true;

    security.acme = {
      acceptTerms = true;
      certs."${domain}" = {
        inherit domain;
        inherit (config.services.caddy) group;
        dnsPropagationCheck = true;
        dnsProvider = "cloudflare";
        dnsResolver = "1.1.1.1:53";
        email = "acme@${domain}";
        environmentFile = config.age.secrets."acme.env".path;
        extraDomainNames = ["*.${domain}"];
        renewInterval = "90d";
      };
    };

    services.caddy.configFile = ./.caddy/Caddyfile;

    system.autoUpgrade = {
      enable = false;
      flake = "github:cosasdepuma/nix";
      dates = "daily";
      operation = "switch";
      persistent = true;
    };
  };

  flake.nixosConfigurations = inputs.self.lib.mkNixos "x86_64-linux" "services";
}
