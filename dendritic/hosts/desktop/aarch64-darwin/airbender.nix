{inputs, ...}: {
  flake.darwinModules.airbender = {config, ...}: let
    hostName = "airbender";
  in {
    imports = with inputs.self.darwinModules; [
      # keep-sorted start
      service-ssh
      settings-locale
      settings-macos
      settings-nix
      settings-nixpkgs
      software-bitwarden
      software-cleanmymac
      software-homebrew
      software-homemanager
      software-obsidian
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
        software-chezmoi
        software-claude
        software-curl
        software-direnv
        software-discord
        software-git
        software-herdr
        software-hushlogin
        software-lsd
        software-ollama
        software-opencode
        software-openspec
        software-pi
        software-spotify
        software-ssh-client
        software-starship
        software-vscode
        software-warp
        software-wget
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
