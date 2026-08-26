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
      everforest-pro = pkgs.vscode-utils.extensionFromVscodeMarketplace {
        name = "everforest-pro";
        publisher = "andreilucaci";
        version = "2.0.0";
        sha256 = "0s6vy9ryfwnpi88rvgxmrwsynhw3zwwks8h404bhn55xwz610378";
      };

      vsconfig = extras:
        lib.mkMerge [
          {
            enableMcpIntegration = true;
            extensions =
              (with pkgs.vscode-extensions; [
                github.copilot-chat
                gruntfuggly.todo-tree
                jnoortheen.nix-ide
                mkhl.direnv
                seatonjiang.gitmoji-vscode
                tamasfe.even-better-toml
              ])
              ++ [everforest-pro]
              ++ lib.optional (config.programs.claude-code.enable or false) pkgs.vscode-extensions.anthropic.claude-code;
            userSettings = {
              "workbench.colorTheme" = "Everforest Pro Dark";
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
