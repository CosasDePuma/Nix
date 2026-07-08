{inputs, ...}: {
  flake.darwinModules.airbender = {
    imports = with inputs.self.darwinModules; [
      # keep-sorted start
      settings-locale
      settings-macos
      settings-nix
      settings-nixpkgs
      software-bat
      software-claude
      software-direnv
      software-discord
      software-gemini
      software-ghostty
      software-git
      software-helium
      software-homebrew
      software-lsd
      software-opencode
      software-spotify
      software-starship
      software-sudo
      software-vscode
      software-wispr
      software-zoxide
      software-zsh
      # keep-sorted end
    ];

    homebrew = {
      brews = [
        "bitwarden-cli"
        "chezmoi"
        "ollama"
        "pi-coding-agent"
      ];
      casks = [
        "telegram"
        "whatsapp"
        "steam"
        "flameshot"
        "font-fira-code-nerd-font"
        "font-jetbrains-mono-nerd-font"
        "the-unarchiver"
        "brave-browser"
        "obsidian"
        "orbstack"
        "utm"
        "whisky"
        "xquartz"
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
