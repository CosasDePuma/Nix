{
  inputs,
  lib,
  ...
}: let
  warpSettings = ''
    [appearance.input]
    input_mode = "waterfall"

    [appearance.text]
    font_name = "FiraCode Nerd Font Mono"
    font_size = 15.0
    ligature_rendering_enabled = true

    [terminal.input]
    honor_ps1 = true
    input_box_type_setting = "classic"

    [warp_drive]
    enabled = false

    [agents.warp_agent.other]
    show_conversation_history = false
  '';
in {
  flake = {
    darwinModules.software-warp = {
      homebrew.casks = ["warp"];
    };

    homeManagerModules.software-warp = {pkgs, ...}: let
      settingsPath =
        if pkgs.stdenv.hostPlatform.isDarwin
        then ".warp/settings.toml"
        else ".config/warp-terminal/settings.toml";
    in {
      imports = [inputs.self.homeManagerModules.fonts-firacode];
      home.file.${settingsPath} = {
        text = lib.mkDefault warpSettings;
      };
    };

    nixosModules.software-warp = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [warp-terminal];
    };
  };
}
