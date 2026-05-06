{ inputs, ... }:
{
  flake.modules.nixos.system-default = {
    imports = with inputs.self.modules.nixos; [
      nix-settings
      nixpkgs-settings
      timezone
      security
    ];
    system.stateVersion = "25.05";
  };

  flake.modules.darwin.system-default = {
    imports = with inputs.self.modules.darwin; [
      timezone
      security
    ];
    ids.gids.nixbld = 350;
    nix = {
      enable = false;
      extraOptions = "extra-platforms = x86_64-darwin aarch64-darwin";
      settings = {
        auto-optimise-store = false;
        experimental-features = [
          "nix-command"
          "flakes"
        ];
      };
    };
    nixpkgs.config.allowUnfree = true;
    system.stateVersion = 6;
  };
}
