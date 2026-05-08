{ inputs, ... }:
{
  flake.modules.nixos.automation =
    { config, pkgs, ... }:
    {
      imports = with inputs.self.modules.nixos; [
        server-defaults
        (inputs.self.factory.homelab-user {
          name = "automation";
          description = "Automation management user";
          home = "/home/users/automation";
          authorizedKeysFile = ./.ssh/authorized_keys;
        })
      ];

      age.secrets."smb.creds".file = ./.smb/smb.creds.age;

      environment.systemPackages = with pkgs; [
        cifs-utils
        handbrake
      ];

      fileSystems = builtins.listToAttrs (
        builtins.map
          (share: {
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
          })
          [
            "backups"
            "media"
          ]
      );

      networking = {
        hostName = "automation";
        hostId = builtins.substring 0 8 (builtins.hashString "md5" "automation");
        usePredictableInterfaceNames = false;
        interfaces."eth0" = {
          useDHCP = false;
          ipv4.addresses = [
            {
              address = "10.0.10.4";
              prefixLength = 24;
            }
          ];
        };
        defaultGateway = {
          interface = "eth0";
          address = "10.0.10.254";
        };
        domain = "home";
        search = [ "home" ];
        nameservers = [ "10.0.10.254" ];
        firewall = {
          enable = true;
          allowedTCPPorts = [ 5678 ];
        };
      };

      services = {
        n8n = {
          enable = true;
          environment.WEBHOOK_URL = "https://automate.kike.wtf";
        };
        openssh.banner = builtins.readFile ./.ssh/banner.txt;
      };

      system.autoUpgrade = {
        enable = true;
        flake = "github:cosasdepuma/nix";
        dates = "daily";
        operation = "switch";
        persistent = true;
      };
    };

  flake.nixosConfigurations = inputs.self.lib.mkNixos "x86_64-linux" "automation";
}
