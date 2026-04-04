{
  config ? throw "not imported as module",
  lib ? throw "not imported as module",
  pkgs ? throw "not imported as module",
  firefox-addons,
  homeModules ? [ ],
  stateVersion ? "25.05",
  ...
}:
let
  username = "rabbit";
in
{
  # ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  # ┃                   Boot                    ┃
  # ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelParams = [ "nvidia-drm.modeset=1" ];
    initrd = {
      availableKernelModules = [
        "xhci_pci"
        "ahci"
        "nvme"
        "usb_storage"
        "usbhid"
        "sd_mod"
      ];
      kernelModules = [
        "nvidia"
        "nvidia_modeset"
        "nvidia_uvm"
        "nvidia_drm"
      ];
    };
    kernelModules = [ "kvm-amd" ];
    extraModulePackages = [ ];
  };

  # ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  # ┃                   Disko                   ┃
  # ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

  disko.devices = {
    disk."main" = {
      device = "/dev/nvme0n1";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            size = "512M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [
                "fmask=0077"
                "dmask=0077"
              ];
            };
          };
          root = {
            size = "100%";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
              extraArgs = [
                "-L"
                "NIXOS"
              ];
            };
          };
        };
      };
    };
    nodev."/tmp" = {
      fsType = "tmpfs";
      mountOptions = [
        "noexec"
        "size=1G"
      ];
    };
  };

  # ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  # ┃                Environment                ┃
  # ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

  environment = {
    pathsToLink = [ "/share/zsh" ]; # https://nix-community.github.io/home-manager/options.xhtml#opt-programs.zsh.enableCompletion
    # --- environment variables
    sessionVariables = {
      # nvidia
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      GBM_BACKEND = "nvidia-drm";
      LIBVA_DRIVER_NAME = "nvidia";
      # wayland
      NIXOS_OZONE_WL = "1";
      XDG_SESSION_TYPE = "wayland";
    };
    # --- applications
    systemPackages = with pkgs; [
      # desktop
      bibata-cursors
      brightnessctl
      kdePackages.dolphin
      mako
      niri
      pavucontrol
      rofi
      awww
      tuigreet
      uwsm
      waybar
      xwayland-satellite

      # terminal
      nano

      # development
      gemini-cli
      opencode

      # miscellaneous
      discord
      spotify
    ];
  };

  # --- desktop
  xdg = {
    portal = {
      enable = true;
      config = {
        common = {
          default = [ "*" ];
          "org.freedesktop.impl.portal.ScreenCast" = [ "gnome" ];
          "org.freedesktop.impl.portal.RemoteDesktop" = [ "gnome" ];
        };
      };
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
        xdg-desktop-portal-gnome
      ];
      wlr.enable = true;
      xdgOpenUsePortal = true;
    };
  };

  # --- fonts
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      nerd-fonts.fira-code
      font-awesome
    ];
  };

  # ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  # ┃                 Hardware                  ┃
  # ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

  hardware = {
    enableAllHardware = true;
    cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

    # --- nvidia
    nvidia = {
      modesetting.enable = true;
      package = config.boot.kernelPackages.nvidiaPackages.latest;
      powerManagement.enable = false;
      powerManagement.finegrained = false;
      open = true;
      nvidiaSettings = true;
    };

    # --- graphics
    graphics = {
      enable = true;
      enable32Bit = true;
    };
  };

  # ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  # ┃               Home Manager                ┃
  # ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {
      inherit firefox-addons stateVersion username;
    };
    users."${username}" = {
      imports = homeModules ++ [ ./home.nix ];
    };
  };

  # ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  # ┃           Internationalisation            ┃
  # ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "es_ES.UTF-8";
      LC_IDENTIFICATION = "es_ES.UTF-8";
      LC_MEASUREMENT = "es_ES.UTF-8";
      LC_MONETARY = "es_ES.UTF-8";
      LC_NAME = "es_ES.UTF-8";
      LC_NUMERIC = "es_ES.UTF-8";
      LC_PAPER = "es_ES.UTF-8";
      LC_TELEPHONE = "es_ES.UTF-8";
      LC_TIME = "es_ES.UTF-8";
    };
  };

  # ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  # ┃                Networking                 ┃
  # ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

  networking = {
    # --- host
    hostName = "wonderland";
    hostId = builtins.substring 0 8 (builtins.hashString "md5" config.networking.hostName);
    # --- interfaces
    networkmanager.enable = true;
    usePredictableInterfaceNames = false;
    # --- dns
    domain = "home";
    search = [
      "home"
      "local"
    ];
    nameservers = [
      "1.1.1.1"
      "8.8.8.8"
    ];
    # --- firewall
    firewall = {
      enable = true;
      allowedTCPPorts = [ ];
      allowedUDPPorts = [ ];
    };
  };

  # ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  # ┃                    Nix                    ┃
  # ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
      persistent = true;
    };
    settings.allowed-users = [ "@wheel" ];
  };

  # ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  # ┃                 NixPkgs                   ┃
  # ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

  nixpkgs.config.allowUnfree = true;

  # ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  # ┃                  Security                 ┃
  # ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

  security = {
    pam = {
      sshAgentAuth.enable = true;
      services."sudo".sshAgentAuth = true;
    };
    rtkit.enable = true;
    sudo-rs = {
      enable = true;
      execWheelOnly = true;
    };
  };

  # ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  # ┃                 Programs                  ┃
  # ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

  programs = {
    dconf.enable = true;
    xwayland.enable = true;
    zsh.enable = true;
  };

  # ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  # ┃                 Services                  ┃
  # ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

  services = {

    # ┌──────────────────────────────────────┐
    # │                 Dbus                 │
    # └──────────────────────────────────────┘

    dbus.enable = true;

    # ┌──────────────────────────────────────┐
    # │                Audio                 │
    # └──────────────────────────────────────┘

    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
      jack.enable = true;

      extraConfig.pipewire."10-low-latency" = {
        "context.properties" = {
          "default.clock.rate" = 48000;
          "default.clock.quantum" = 256;
          "default.clock.min-quantum" = 128;
          "default.clock.max-quantum" = 512;
        };
      };
    };
    pulseaudio.enable = false;

    # ┌──────────────────────────────────────┐
    # │           Display Manager            │
    # └──────────────────────────────────────┘

    greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd niri-session";
          user = "greeter";
        };
      };
    };

    # ┌──────────────────────────────────────┐
    # │               Desktop                │
    # └──────────────────────────────────────┘

    xserver = {
      enable = true;
      videoDrivers = [ "nvidia" ];
      xkb = {
        layout = "us,es";
        options = "grp:lalt_lshift_toggle";
      };
    };
  };

  # ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  # ┃              Specialisations              ┃
  # ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

  specialisation = {
    # --- gaming
    gaming = {
      inheritParentConfig = true;
      configuration = {
        environment = {
          sessionVariables = {
            GAMEMODERUNEXEC = "1";
            MANGOHUD = "1";
            PROTON_ENABLE_WAYLAND = "1";
            PROTON_USE_WINED3D = "0";
            SDL_VIDEODRIVER = "wayland";
            STEAM_USE_WAYLAND = "1";
          };
          systemPackages = with pkgs; [
            mangohud
            gamemode
            wayland
          ];
        };
        programs = {
          steam = {
            dedicatedServer.openFirewall = true;
            enable = true;
            extraCompatPackages = with pkgs; [ proton-ge-bin ];
            remotePlay.openFirewall = true;
          };
        };
      };
    };
  };

  # ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  # ┃                  System                   ┃
  # ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

  system = { inherit stateVersion; };

  # ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  # ┃                 Systemd                   ┃
  # ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

  systemd.tmpfiles.rules = [ "d /var/lib/alsa 0755 root root -" ];

  # ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  # ┃                   Time                    ┃
  # ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

  time.timeZone = "Europe/Madrid";

  # ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  # ┃                   Users                   ┃
  # ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

  users.users."${username}" = {
    isNormalUser = true;
    description = "White Rabbit";
    shell = pkgs.zsh;
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };

  users.users."greeter" = {
    isSystemUser = true;
    group = "greeter";
    description = "greetd greeter user";
  };

  users.groups = {
    audio = { };
    greeter = { };
  };
}
