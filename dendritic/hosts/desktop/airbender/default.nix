{inputs, ...}: {
  flake.modules.darwin.airbender = {
    imports = with inputs.self.modules.darwin; [
      desktop-defaults
      # --- software
      bat-software
      claude-software
      direnv-software
      discord-software
      gemini-software
      ghostty-software
      homebrew-software
      lsd-software
      opencode-software
      spotify-software
      starship-software
      zsh-software
    ];

    homebrew = {
      brews = [
        "bitwarden-cli"
        "chezmoi"
        "git"
        "zoxide"
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
            "visual-studio-code"
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
