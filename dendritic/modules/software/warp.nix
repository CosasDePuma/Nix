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

    [agents.third_party]
    cli_agent_toolbar_chip_selection_setting = { custom = { left = ["file_attach"], right = [{ context_chip = "working_directory" }, { context_chip = "git_branch_status" }] } }
  '';

  claudeCodeWarp = {
    owner = "warpdotdev";
    repo = "claude-code-warp";
    rev = "e0e18e162aa5ec97a6d4cecdf66b08b75eb1e149";
    hash = "sha256-ZMSQBLd9kCZfVqZX6VvMn6KnyM8a5zuTu+5ctltG5GQ=";
  };
in {
  flake = {
    darwinModules.software-warp = {
      homebrew.casks = ["warp"];
    };

    homeManagerModules.software-warp = {
      pkgs,
      config,
      ...
    }: let
      settingsPath =
        if pkgs.stdenv.hostPlatform.isDarwin
        then ".warp/settings.toml"
        else ".config/warp-terminal/settings.toml";
    in {
      imports = [inputs.self.homeManagerModules.fonts-firacode];
      config = lib.mkMerge [
        {
          home.file.${settingsPath} = {
            text = lib.mkDefault warpSettings;
          };
        }
        (lib.mkIf (config.programs.opencode.enable or false) {
          programs.opencode.settings.plugin = ["@warp-dot-dev/opencode-warp"];
        })
        (lib.mkIf (config.programs.claude-code.enable or false) {
          programs.claude-code.plugins."warp" = "${pkgs.fetchFromGitHub claudeCodeWarp}/plugins/warp";
        })
      ];
    };

    nixosModules.software-warp = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [warp-terminal];
    };
  };
}
