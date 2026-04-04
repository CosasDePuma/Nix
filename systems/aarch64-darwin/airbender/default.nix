{
  user ? "pumita",
  ...
}:
{
  # ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  # ┃                 Homebrew                  ┃
  # ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

  homebrew = {
    enable = true;
    global = {
      autoUpdate = true;
      brewfile = true;
    };
    onActivation = {
      autoUpdate = true;
      cleanup = "zap";
    };

    # --- cli applications
    brews = [
      "bat"
      "bitwarden-cli"
      "chezmoi"
      "direnv"
      "git"
      "lsd"
      "starship"
      "zoxide"
      "zsh"
      # --- ai tools
      "gemini-cli"
      "ollama"
      "opencode"
    ];

    # --- graphical applications
    casks =
      let
        appsDir = "/Applications/Homebrew";
        organize =
          folder: apps:
          builtins.map (name: {
            inherit name;
            args = {
              appdir = "${appsDir}/${folder}";
            };
          }) apps;
      in
      builtins.concatLists [
        (organize "Communication" [
          "discord"
          "telegram"
          "whatsapp"
        ])
        (organize "Development" [
          "claude-code"
          "ghostty"
          "kiro"
          "visual-studio-code"
        ])
        (organize "Entertainment" [
          "spotify"
          "steam"
        ])
        (organize "System" [
          "flameshot"
          "font-fira-code-nerd-font"
          "font-jetbrains-mono-nerd-font"
          "the-unarchiver"
        ])
        (organize "Utilities" [
          "brave-browser"
          "obsidian"
        ])
        (organize "Virtualization" [
          "orbstack"
          "utm"
          "whisky"
          "xquartz"
        ])
      ];

    # --- app store
    masApps = {
      "cleanmymac" = 1339170533;
      "steamlink" = 1246969117;
      "wireguard" = 1451685025;
    };
  };

  # ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  # ┃                    IDs                    ┃
  # ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

  ids.gids.nixbld = 350;

  # ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  # ┃                    Nix                    ┃
  # ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

  nix = {
    enable = false;
    extraOptions = "extra-platforms = x86_64-darwin aarch64-darwin";
    settings.auto-optimise-store = false;
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  # ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  # ┃                  Nixpkgs                  ┃
  # ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

  nixpkgs.config.allowUnfree = true;

  # ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  # ┃                  Security                 ┃
  # ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

  security.pam.services.sudo_local = {
    touchIdAuth = true;
    reattach = true;
  };

  # ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  # ┃                  System                   ┃
  # ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

  system = {
    stateVersion = 6;
    primaryUser = user;
    defaults = {
      # --- dock
      dock = {
        autohide = true;
      };

      # --- finder
      finder = {
        # --- desktop
        CreateDesktop = false;
        ShowExternalHardDrivesOnDesktop = true;
        ShowHardDrivesOnDesktop = true;
        ShowMountedServersOnDesktop = true;
        ShowRemovableMediaOnDesktop = true;

        # --- folder
        _FXSortFoldersFirst = true;
        AppleShowAllExtensions = true;
        AppleShowAllFiles = true;
        FXPreferredViewStyle = "clmv";
        NewWindowTarget = "Home";
        QuitMenuItem = true;
        ShowPathbar = true;
        ShowStatusBar = true;
      };
    };
  };

  # ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  # ┃                   Time                    ┃
  # ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

  time.timeZone = "Europe/Madrid";
}
