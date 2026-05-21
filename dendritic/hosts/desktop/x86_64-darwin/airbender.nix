{inputs, ...}: {
  flake.darwinModules.airbender = {
    imports = with inputs.self.darwinModules; [
      settings-locale
      settings-macos
      settings-nix
      settings-nixpkgs
      software-bat
      software-claude
      software-direnv
      software-discord
      software-gemini
      software-git
      software-ghostty
      software-homebrew
      software-lsd
      software-opencode
      software-spotify
      software-starship
      software-sudo
      software-vscode
      software-zoxide
      software-zsh
    ];

    homebrew = {
      brews = [
        "bitwarden-cli"
        "chezmoi"
        "ollama"
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
            "telegram"
            "whatsapp"
          ])
          (organize "Development" [
            "kiro"
          ])
          (organize "Entertainment" [
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
