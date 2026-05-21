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
              ++ config.my.vscode-extraExtensions;
            userSettings = {
              "terminal.integrated.fontFamily" = "'FiraCode Nerd Font Mono', monospace";
              "explorer.fileNesting.enabled" = true;
              "explorer.fileNesting.patterns" = {
                "flake.nix" = "flake.lock";
              };
              "terminal.integrated.fontLigatures.enabled" = true;
              "todo-tree.tree.hideTreeWhenEmpty" = true;
            };
          }
          extras
        ];
    in {
      options.my.vscode-extraExtensions = lib.mkOption {
        type = lib.types.listOf lib.types.package;
        default = [];
        description = "Additional VSCode extensions to install.";
        example = with pkgs.vscode-extensions; [
          "ms-python.python"
          "esbenp.prettier-vscode"
        ];
      };
      config.programs.vscode = {
        enable = lib.mkDefault true;
        profiles = {
          "default" = vsconfig {};
          "python" = vsconfig {
            extensions = with pkgs.vscode-extensions; [ms-python.python];
            userSettings."explorer.fileNesting.patterns" = {
              "pyproject.toml" = "poetry.lock,uv.lock";
            };
          };
        };
      };
    };

    nixosModules.software-vscode = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [vscode];
    };
  };
}
