{inputs, ...}: {
  flake.darwinModules.airbender = {config, ...}: {
    imports = with inputs.self.darwinModules; [
      # keep-sorted start
      fonts-firacode
      fonts-jetbrains
      settings-locale
      settings-macos
      settings-nix
      settings-nixpkgs
      software-chezmoi
      software-cleanmymac
      software-ghostty
      software-homebrew
      software-homemanager
      software-obsidian
      software-ollama
      software-pi
      software-steam
      software-sudo
      software-unar
      software-whatsapp
      software-wireguard
      software-wisprflow
      # keep-sorted end
    ];

    home-manager.users.${config.system.primaryUser} = {
      home.stateVersion = "25.05";
      imports = with inputs.self.homeManagerModules; [
        # keep-sorted start
        software-antigravity
        software-bat
        software-bitwarden
        software-claude
        software-direnv
        software-discord
        software-git
        software-lsd
        software-opencode
        software-spotify
        software-starship
        software-vscode
        software-zoxide
        software-zsh
        # keep-sorted end
      ];
    };

    system.primaryUser = "pumita";
  };

  flake.darwinConfigurations = inputs.self.lib.mkDarwin "aarch64-darwin" "airbender";
}
