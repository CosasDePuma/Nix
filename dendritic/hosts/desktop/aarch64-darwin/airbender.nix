{inputs, ...}: {
  flake.darwinModules.airbender = {config, ...}: let
    hostName = "airbender";
  in {
    imports = with inputs.self.darwinModules; [
      # keep-sorted start
      fonts-jetbrains
      service-ssh
      settings-locale
      settings-macos
      settings-nix
      settings-nixpkgs
      software-chezmoi
      software-cleanmymac
      software-ghostty
      software-herdr
      software-homebrew
      software-homemanager
      software-obsidian
      software-ollama
      software-pi
      software-steam
      software-sudo
      software-unar
      software-warp
      software-whatsapp
      software-wireguard
      software-wisprflow
      # keep-sorted end
    ];

    home-manager.users.${config.system.primaryUser} = {
      home.stateVersion = "26.11";
      imports = with inputs.self.homeManagerModules; [
        # keep-sorted start
        software-antigravity
        software-bat
        software-bitwarden
        software-claude
        software-direnv
        software-discord
        software-git
        software-herdr
        software-lsd
        software-opencode
        software-spotify
        software-starship
        software-vscode
        software-warp
        software-zoxide
        software-zsh
        # keep-sorted end
      ];
    };

    networking = {
      inherit hostName;
      computerName = hostName;
      localHostName = hostName;
    };

    system.primaryUser = "pumita";
  };

  flake.darwinConfigurations = inputs.self.lib.mkDarwin "aarch64-darwin" "airbender";
}
