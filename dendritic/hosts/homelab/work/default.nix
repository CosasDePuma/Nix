{inputs, ...}: {
  flake.nixosModules.work = {
    config,
    pkgs,
    ...
  }: {
    imports = with inputs.self.nixosModules; [
      disko-impermanence-server
      service-ssh
      settings-locale
      settings-nix
      settings-nixpkgs
      system-impermanence
    ];

    age.identityPaths = builtins.map (key: key.path) config.services.openssh.hostKeys;

    hardware.enableAllHardware = true;

    users = {
      mutableUsers = false;
      groups = {
        "sshusers" = {};
        "users" = {};
      };
      users."work" = {
        isNormalUser = true;
        description = "Work management user";
        home = "/home/users/work";
        uid = 1000;
        group = "users";
        useDefaultShell = true;
        hashedPassword = null;
        extraGroups = [
          "wheel"
          "sshusers"
        ];
        openssh.authorizedKeys.keys = pkgs.lib.strings.splitString "\n" (builtins.readFile ./.ssh/authorized_keys);
      };
    };

    environment.systemPackages = with pkgs; [
      podman-compose
    ];

    virtualisation.podman = {
      enable = true;
      defaultNetwork.settings.dns_enabled = true;
    };

    virtualisation.oci-containers = {
      backend = "podman";
      containers = {
        presenton = {
          image = "ghcr.io/presenton/presenton:latest";
          ports = ["3000:3000"];
          volumes = [
            "/var/lib/presenton:/app/data"
          ];
          environment = {
            NODE_ENV = "production";
          };
        };
      };
    };

    networking = {
      hostName = "work";
      hostId = builtins.substring 0 8 (builtins.hashString "md5" "work");
      usePredictableInterfaceNames = false;
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
      domain = "home";
      search = ["home"];
      nameservers = ["10.0.10.254"];
      firewall = {
        enable = true;
        allowedTCPPorts = [
          3000
        ];
      };
    };

    environment.persistence."/nix/persist" = {
      directories = [
        "/etc/ssh"
        "/var/lib/containers"
        "/var/lib/presenton"
        "/root"
      ];
    };

    nixpkgs.config.allowUnfree = false;

    system.autoUpgrade = {
      enable = false;
      flake = "github:cosasdepuma/nix";
      dates = "daily";
      operation = "switch";
      persistent = true;
    };
  };

  flake.nixosConfigurations = inputs.self.lib.mkNixos "x86_64-linux" "work";
}
