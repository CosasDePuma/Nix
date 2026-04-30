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
  #region boot
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
  #endregion

  # ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  # ┃                   Disko                   ┃
  # ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
  #region disko
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
  #endregion

  # ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  # ┃                Environment                ┃
  # ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
  #region environment
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
      niri
      pavucontrol
      rofi
      awww
      tuigreet
      uwsm
      waybar
      xwayland-satellite
      libnotify

      # terminal
      nano

      # development
      gemini-cli
      opencode

      # miscellaneous
      discord
      spotify
      burpsuite
      ftb-app
    ];
  };

  # --- desktop
  xdg = {
    portal = {
      enable = true;
      config = {
        common = {
          default = [ "*" ];
          "org.freedesktop.impl.portal.ScreenCast" = [ "wlr" ];
          "org.freedesktop.impl.portal.RemoteDesktop" = [ "gnome" ];
        };
      };
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
        xdg-desktop-portal-gnome
      ];
      xdgOpenUsePortal = true;
      wlr.enable = true;
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
  #endregion

  # ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  # ┃                 Hardware                  ┃
  # ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
  #region hardware
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
  #endregion

  # ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  # ┃               Home Manager                ┃
  # ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
  #region home-manager
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
  #endregion

  # ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  # ┃           Internationalisation            ┃
  # ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
  #region internationalisation
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
  #endregion

  # ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  # ┃                Networking                 ┃
  # ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
  #region networking
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
  #endregion

  # ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  # ┃                    Nix                    ┃
  # ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
  #region nix
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
  #endregion

  # ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  # ┃                 NixPkgs                   ┃
  # ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
  #region nixpkgs
  nixpkgs.config.allowUnfree = true;
  #endregion

  # ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  # ┃                  Security                 ┃
  # ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
  #region security
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
  #endregion

  # ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  # ┃                 Programs                  ┃
  # ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
  #region programs
  programs = {
    dconf.enable = true;
    xwayland.enable = true;
    zsh.enable = true;
  };
  #endregion

  # ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  # ┃                 Services                  ┃
  # ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
  #region services
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
    # │                  AI                  │
    # └──────────────────────────────────────┘

    ollama.enable = true;

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
  #endregion

  # ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  # ┃              Specialisations              ┃
  # ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
  #region specialisations
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
  #endregion

  # ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  # ┃                  System                   ┃
  # ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
  #region system
  system = { inherit stateVersion; };
  #endregion

  # ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  # ┃                 Systemd                   ┃
  # ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
  #region systemd
  systemd.tmpfiles.rules = [ "d /var/lib/alsa 0755 root root -" ];
  #endregion

  # ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  # ┃                   Time                    ┃
  # ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
  #region time
  time.timeZone = "Europe/Madrid";
  #endregion

  # ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  # ┃                   Users                   ┃
  # ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
  #region users
  users = {
    # --- users
    users = {
      "${username}" = {
        isNormalUser = true;
        description = "White Rabbit";
        shell = pkgs.zsh;
        extraGroups = [
          "networkmanager"
          "wheel"
        ];
      };
      "greeter" = {
        isSystemUser = true;
        group = "greeter";
        description = "greetd greeter user";
      };
    };
    # --- groups
    groups = {
      audio = { };
      greeter = { };
    };
  };
  #endregion
}
