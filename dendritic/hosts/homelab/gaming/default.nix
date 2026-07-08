{inputs, ...}: {
  flake.nixosModules.gaming = {
    config,
    pkgs,
    ...
  }: {
    imports = with inputs.self.nixosModules; [
      server-defaults
      (inputs.self.factory.homelab-user {
        name = "gamer";
        description = "Gaming management user";
        home = "/home/users/gamer";
        authorizedKeysFile = ./.ssh/authorized_keys;
      })
    ];

    age.secrets."smb.creds".file = ./.smb/smb.creds.age;

    environment.systemPackages = with pkgs; [
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
      }) ["backups"]
    );

    networking = {
      hostName = "gaming";
      hostId = builtins.substring 0 8 (builtins.hashString "md5" "gaming");
      usePredictableInterfaceNames = false;
      interfaces."eth0" = {
        useDHCP = false;
        ipv4.addresses = [
          {
            address = "10.0.10.5";
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
        allowedTCPPorts = [25565];
      };
    };

    system.autoUpgrade = {
      enable = true;
      flake = "github:cosasdepuma/nix";
      dates = "daily";
      operation = "switch";
      persistent = true;
    };

    virtualisation = {
      podman = {
        enable = true;
        autoPrune = {
          enable = true;
          dates = "weekly";
          flags = ["--all"];
        };
        dockerCompat = true;
      };
      oci-containers.backend = "podman";
      # minecraft-ocean container is WIP — image TBD
    };
  };

  flake.nixosConfigurations = inputs.self.lib.mkNixos "x86_64-linux" "gaming";
}
