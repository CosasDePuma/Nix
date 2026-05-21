{inputs, ...}: {
  flake.modules.nixos.proxy = {
    config,
    pkgs,
    ...
  }: let
    domain = "kike.wtf";
  in {
    imports = with inputs.self.modules.nixos; [
      server-defaults
      (inputs.self.factory.homelab-user {
        name = "proxy";
        description = "Proxy management user";
        home = "/home/users/proxy";
        authorizedKeysFile = ./.ssh/authorized_keys;
      })
    ];

    age.secrets = {
      "acme.env".file = ./.acme/acme.env.age;
      "homepage.env".file = ./.homepage/homepage.env.age;
    };

    disko.devices.nodev."/tmp".mountOptions = [
      "noexec"
      "size=1G"
    ];

    environment.systemPackages = with pkgs; [
      curl
      openssl
    ];

    networking = {
      hostName = "proxy";
      hostId = builtins.substring 0 8 (builtins.hashString "md5" "proxy");
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
        allowedTCPPorts = [443];
      };
    };

    nixpkgs.config.allowUnfree = false;

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

    services = {
      caddy = {
        enable = true;
        enableReload = true;
        logFormat = "level INFO";
        configFile = ./.caddy/Caddyfile;
      };

      homepage-dashboard = let
        homepageConfig = builtins.fromJSON (builtins.readFile ./.homepage/homepage.json);
      in {
        inherit (homepageConfig) services;
        enable = true;
        listenPort = 8082;
        allowedHosts = "*";
        environmentFiles = [config.age.secrets."homepage.env".path];
        settings = {
          inherit (homepageConfig) layout;
          color = "slate";
          title = "Kike's Homelab";
          description = "A collection of services running on Kike's Homelab";
          hideVersion = true;
          useEqualHeights = true;
        };
      };
    };

    system.autoUpgrade = {
      enable = false;
      flake = "github:cosasdepuma/nix";
      dates = "daily";
      operation = "switch";
      persistent = true;
    };
  };

  flake.nixosConfigurations = inputs.self.lib.mkNixos "x86_64-linux" "proxy";
}
