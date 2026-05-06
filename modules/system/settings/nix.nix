{
  flake.modules.nixos.nix-settings = {
    nix = {
      extraOptions = ''
        experimental-features = nix-command flakes
      '';
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 7d";
        persistent = true;
      };
      settings.allowed-users = [ "@wheel" ];
    };
  };
}
