{ inputs, lib, ... }:
{
  flake.modules.nixos.system-defaults = {
    imports = with inputs.self.modules.nixos; [
      locale-settings
      nix-settings
      nixpkgs-settings
      security-settings
    ];
    system.stateVersion = lib.mkDefault "25.05";
  };

  flake.modules.darwin.system-defaults = {
    imports = with inputs.self.modules.darwin; [
      locale-settings
      macos-settings
      nix-settings
      nixpkgs-settings
      security-settings
    ];
    ids.gids.nixbld = 350;
    system.stateVersion = lib.mkDefault 6;
  };
}
