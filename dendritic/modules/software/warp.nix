{
  inputs,
  lib,
  ...
}: let
  warpSettings = ''
    [appearance.text]
    font_name = "FiraCode Nerd Font Mono"
    font_size = 15.0
    ligature_rendering_enabled = true
  '';
in {
  flake = {
    darwinModules.software-warp = {
      imports = [inputs.self.darwinModules.fonts-firacode];
      homebrew.casks = ["warp"];
    };

    homeManagerModules.software-warp = {pkgs, ...}: let
      settingsPath =
        if pkgs.stdenv.hostPlatform.isDarwin
        then ".warp/settings.toml"
        else ".config/warp-terminal/settings.toml";
    in {
      home.file.${settingsPath} = {
        text = lib.mkDefault warpSettings;
      };
    };

    nixosModules.software-warp = {pkgs, ...}: {
      imports = [inputs.self.nixosModules.fonts-firacode];
      environment.systemPackages = with pkgs; [warp-terminal];
    };
  };
}
