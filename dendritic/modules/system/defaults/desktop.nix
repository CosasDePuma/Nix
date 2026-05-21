{
  inputs,
  lib,
  ...
}: {
  flake.modules = {
    nixos.desktop-defaults = _: {
      imports = with inputs.self.modules.nixos; [
        settings-locale
        settings-nix
        settings-nixpkgs
        settings-security
      ];
      system.stateVersion = lib.mkDefault "25.05";
    };

    darwin.desktop-defaults = _: {
      imports = with inputs.self.modules.darwin; [
        settings-locale
        settings-macos
        settings-nix
        settings-nixpkgs
        settings-security
      ];
      ids.gids.nixbld = 350;
      system.stateVersion = lib.mkDefault 6;
    };
  };
}
