{inputs, ...}: {
  flake.nixosModules.wonderland = {config, ...}: {
    imports = with inputs.self.nixosModules; [
      # keep-sorted start
      boot-efi
      boot-loader-grub
      cpu-amd
      disko-impermanence
      gpu-nvidia
      hardware-defaults
      hardware-nvme
      meta-ai
      meta-terminal
      rice-omarchy
      service-ssh
      settings-locale
      settings-nix
      software-brave
      software-discord
      software-homemanager
      software-networkmanager
      software-spotify
      software-tailscale
      software-vscode
      software-windowsvm
      software-wow
      system-impermanence
      # keep-sorted end
    ];

    age.secrets."tailscale-preauth-key".file = ./.tailscale/preauth-key.age;

    # Admin's own device: pulls in the router's advertised LAN route via
    # tag:admin on the preauth key (see the router's ACL) rather than
    # advertising anything itself.
    services.tailscale = {
      authKeyFile = config.age.secrets."tailscale-preauth-key".path;
      extraUpFlags = [
        "--login-server=https://vpn.kike.wtf"
        "--accept-routes"
      ];
    };

    home-manager.users.wizard = {
      home.stateVersion = "26.11";
      home.file = let
        gameDir = "Games/WoW/ChromieCraft_3.3.5a";
      in {
        "${gameDir}/realmlist.wtf".text = "set realmlist wow.game.kike.wtf";
        "${gameDir}/Data/enUS/realmlist.wtf".text = "set realmlist wow.game.kike.wtf";
      };
      imports = with inputs.self.homeManagerModules; [
        # keep-sorted start
        meta-ai
        meta-terminal
        profile-cosasdepuma
        rice-omarchy
        software-brave
        software-discord
        software-spotify
        software-vscode
        software-windowsvm
        software-wow
        themes-everforest
        # keep-sorted end
      ];
    };

    disko.devices.disk.main.device = "/dev/disk/by-id/nvme-eui.0025384b51424d22";
    # Root tmpfs's shared 2G default filled up: the WoW client alone is ~2GB
    # and briefly sat on it (not yet persisted the first time it was
    # extracted), leaving no room for anything else, including nix's own
    # build/cache writes.
    # mode=755 explicitly: plain tmpfs "defaults" is world-writable (1777,
    # same as /tmp), which nix's sandbox refuses to build under since "/" is
    # an ancestor of every build directory.
    disko.devices.nodev."/".mountOptions = ["defaults" "size=50G" "mode=755"];

    environment.persistence."/nix/persist".users.wizard = {
      directories = [
        # keep-sorted start
        ".claude"
        ".config"
        ".copilot"
        ".gemini"
        ".local"
        ".pi"
        ".ssh"
        ".vscode"
        "Documents"
        "Downloads"
        "Games"
        "Windows"
        # keep-sorted end
      ];
      files = [
        # keep-sorted start
        ".bash_history"
        ".zsh_history"
        # keep-sorted end
      ];
    };

    networking.hostName = "wonderland";

    system.stateVersion = "26.11";

    users.users.wizard = {
      initialPassword = "wizard";
      isNormalUser = true;
      extraGroups = ["wheel" "networkmanager" "video" "audio" "sshusers" "docker"];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKh1YtKaItcNzC3RGez38zaJ0geelyrb6AFV73OqLchv"
      ];
    };
  };

  flake.nixosConfigurations = inputs.self.lib.mkNixos "x86_64-linux" "wonderland";
}
