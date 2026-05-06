{ inputs, ... }:
let
  user = "pumita";
in
{
  flake.modules.darwin.airbender = {
    imports = with inputs.self.modules.darwin; [
      system-default
    ];

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
        "gemini-cli"
        "ollama"
        "opencode"
        "pi-coding-agent"
      ];
      casks =
        let
          appsDir = "/Applications/Homebrew";
          organize =
            folder: apps:
            builtins.map (name: {
              inherit name;
              args.appdir = "${appsDir}/${folder}";
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
      masApps = {
        "cleanmymac" = 1339170533;
        "steamlink" = 1246969117;
        "wireguard" = 1451685025;
      };
    };

    system = {
      defaults = {
        dock.autohide = true;
        finder = {
          CreateDesktop = false;
          ShowExternalHardDrivesOnDesktop = true;
          ShowHardDrivesOnDesktop = true;
          ShowMountedServersOnDesktop = true;
          ShowRemovableMediaOnDesktop = true;
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
      primaryUser = user;
    };
  };

  flake.darwinConfigurations = inputs.self.lib.mkDarwin "aarch64-darwin" "airbender";
}
