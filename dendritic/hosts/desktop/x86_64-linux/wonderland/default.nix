{inputs, ...}: {
  flake.nixosModules.wonderland = {
    imports = with inputs.self.nixosModules; [
      # keep-sorted start
      meta-terminal
      rice-omarchy
      service-ssh
      settings-locale
      settings-nix
      software-homemanager
      software-sudo
      software-warp
      # keep-sorted end
    ];

    home-manager.users.wizard = {
      home.stateVersion = "26.11";
      imports = with inputs.self.homeManagerModules; [
        # keep-sorted start
        meta-terminal
        profile-cosasdepuma
        rice-omarchy
        software-warp
        # keep-sorted end
      ];
    };

    networking.hostName = "wonderland";

    users.users.wizard = {
      isNormalUser = true;
      extraGroups = ["wheel" "networkmanager" "video" "audio"];
    };
  };

  flake.nixosConfigurations = inputs.self.lib.mkNixos "x86_64-linux" "wonderland";
}
