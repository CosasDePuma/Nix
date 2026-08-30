{inputs, ...}: {
  flake.nixosModules.wonderland = {
    lib,
    pkgs,
    ...
  }: {
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

    home-manager.users.wizard = {pkgs, ...}: {
      home.stateVersion = "26.11";
      home.packages = [pkgs.tailscale-systray];
      home.file = let
        gameDir = "Games/WoW/ChromieCraft_3.3.5a";
      in {
        "${gameDir}/realmlist.wtf".text = "set realmlist wow.game.kike.wtf";
        "${gameDir}/Data/enUS/realmlist.wtf".text = "set realmlist wow.game.kike.wtf";
      };
      # tailscale's Linux CLI has no GUI of its own -- this gives the
      # tray icon + pkexec-driven up/down that omarchy-shell's tailscale
      # panel alone doesn't provide (login now happens interactively
      # here instead of the old auto-connecting authKeyFile).
      systemd.user.services.tailscale-systray = {
        Unit = {
          Description = "Tailscale systray";
          PartOf = ["graphical-session.target"];
          After = ["graphical-session.target"];
          StartLimitIntervalSec = 60;
          StartLimitBurst = 10;
        };
        Service = {
          ExecStart = "${pkgs.tailscale-systray}/bin/tailscale-systray";
          Restart = "on-failure";
          RestartSec = "2s";
        };
        Install.WantedBy = ["graphical-session.target"];
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
    # security.polkit.enable alone doesn't set up the setuid pkexec wrapper
    # (opt-in via enablePkexecWrapper) -- without it, pkexec resolves to the
    # unprivileged nix store binary and tailscale-systray's up/down fail
    # with "pkexec must be setuid root".
    security.polkit.enablePkexecWrapper = true;

    # `tailscale` in PATH is a symlink to the same argv[0]-dispatched
    # multicall binary as `tailscaled`; pkexec canonicalizes the path
    # before exec'ing it (TOCTOU safety), collapsing that symlink so
    # `pkexec tailscale up` fails with "Tailscaled does not take
    # non-flag arguments". `exec -a tailscale bin/tailscaled` alone
    # doesn't fix it either: bin/tailscaled is itself a makeWrapper
    # shebang script, and shebang invocation makes the kernel discard
    # a custom argv[0] and replace $0 with the literal script path --
    # so the "tailscale" identity never survives into its own
    # `exec -a "$0" .../.tailscaled-wrapped`. Skip that layer and pin
    # argv[0] directly against the real (unwrapped) binary instead.
    environment.systemPackages = [
      (lib.hiPrio (pkgs.writeShellScriptBin "tailscale" ''
        exec -a tailscale ${pkgs.tailscale}/bin/.tailscaled-wrapped "$@"
      ''))
    ];
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
