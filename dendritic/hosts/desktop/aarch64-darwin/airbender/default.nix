{inputs, ...}: {
  flake.darwinModules.airbender = {config, ...}: let
    hostName = "airbender";
  in {
    imports = with inputs.self.darwinModules; [
      # keep-sorted start
      meta-lang-javascript
      service-ssh
      settings-locale
      settings-macos
      settings-nix
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
        meta-ai
        meta-terminal
        profile-cosasdepuma
        software-discord
        software-spotify
        software-vscode
        software-warp
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
