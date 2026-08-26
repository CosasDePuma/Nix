{lib, ...}: {
  flake = {
    darwinModules.software-vscode = {
      homebrew.casks = ["visual-studio-code"];
    };

    homeManagerModules.software-vscode = {
      config,
      pkgs,
      ...
    }: let
      vsconfig = extras:
        lib.mkMerge [
          {
            enableMcpIntegration = true;
            extensions = with pkgs.vscode-extensions;
              [
                github.copilot-chat
                gruntfuggly.todo-tree
                jnoortheen.nix-ide
                mkhl.direnv
                seatonjiang.gitmoji-vscode
                tamasfe.even-better-toml
              ]
              ++ lib.optional (config.programs.claude-code.enable or false) anthropic.claude-code;
          }
          extras
        ];
    in {
      config.programs.vscode = {
        enable = lib.mkDefault true;
        profiles = {
          "default" = vsconfig {};
          "python" = vsconfig {
            extensions = with pkgs.vscode-extensions; [ms-python.python];
          };
        };
      };

      config.home.file = lib.mkIf (config.programs.vscode.enable or false) {
        ".config/Code/User/settings.json".source =
          config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.local/state/theme/vscode.json";
      };
    };

    nixosModules.software-vscode = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [vscode];
    };
  };
}
