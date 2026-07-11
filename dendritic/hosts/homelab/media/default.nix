{inputs, ...}: {
  flake.nixosModules.media = {
    config,
    pkgs,
    ...
  }: {
    imports = with inputs.self.nixosModules; [
      server-defaults
      service-jellyfin
      service-komga
      service-qbittorrent
      service-borgbackup
      (inputs.self.factory.homelab-user {
        name = "media";
        description = "Media management user";
        home = "/home/users/media";
        authorizedKeysFile = ./.ssh/authorized_keys;
      })
    ];

    age.secrets."smb.creds".file = ./.smb/smb.creds.age;

    environment.systemPackages = with pkgs; [
      cifs-utils
      mediainfo
      jellyfin-web
      jellyfin-ffmpeg
      wget
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
      hostName = "media";
      hostId = builtins.substring 0 8 (builtins.hashString "md5" "media");
      usePredictableInterfaceNames = false;
      interfaces."eth0" = {
        useDHCP = false;
        ipv4.addresses = [
          {
            address = "10.0.10.2";
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
          8096
          config.services.komga.settings.server.port
          config.services.qbittorrent.webuiPort
          config.services.qbittorrent.torrentingPort
        ];
        allowedUDPPorts = [
          config.services.qbittorrent.torrentingPort
        ];
      };
    };

    environment.persistence."/nix/persist" = {
      directories = [
        "/var/lib/jellyfin"
        "/var/lib/komga"
        "/var/lib/qbittorrent"
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

  flake.nixosConfigurations = inputs.self.lib.mkNixos "x86_64-linux" "media";
}
