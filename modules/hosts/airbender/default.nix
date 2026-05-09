{inputs, ...}: {
  flake.modules.darwin.airbender = {
    imports = with inputs.self.modules.darwin; [
      system-defaults
      # --- software
      claude-software
      gemini-software
      homebrew-software
    ];

    homebrew = {
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
        "ollama"
        "opencode"
        "pi-coding-agent"
      ];
      casks = let
        appsDir = "/Applications/Homebrew";
        organize = folder: apps:
          builtins.map (name: {
            inherit name;
            args.appdir = "${appsDir}/${folder}";
          })
          apps;
      in
        builtins.concatLists [
          (organize "Communication" [
            "discord"
            "telegram"
            "whatsapp"
          ])
          (organize "Development" [
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

    system.primaryUser = "pumita";
  };

  flake.darwinConfigurations = inputs.self.lib.mkDarwin "aarch64-darwin" "airbender";
}
