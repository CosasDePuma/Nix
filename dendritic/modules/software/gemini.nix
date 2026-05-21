{
  inputs,
  lib,
  ...
}: {
  flake = {
    darwinModules.software-gemini = {
      homebrew = {
        brews = ["gemini-cli"];
        casks = ["google-gemini"];
      };
    };

    homeManagerModules.software-gemini = {
      config,
      pkgs,
      ...
    }: {
      imports = with inputs.self.homeManagerModules; [software-mcp];
      config = lib.mkMerge [
        {
          programs.gemini-cli = {
            context.fileName = lib.mkDefault ''
              AGENTS.md
              CLAUDE.md
              CONTEXT.md
              GEMINI.md
            '';
            enable = lib.mkDefault true;
            enableMcpIntegration = lib.mkDefault true;
            settings = {
              ide.enable = lib.mkDefault true;
              general = {
                preferredEditor = lib.mkDefault "code";
                previewFeatures = lib.mkDefault true;
              };
              privacy.usageStatisticsEnabled = lib.mkDefault false;
            };
          };
        }
        (lib.mkIf config.programs.vscode.enable {
          my.vscode-extraExtensions = with pkgs.vscode-extensions; [Google.gemini-cli-vscode-ide-companion];
        })
      ];
    };

    nixosModules.software-gemini = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [gemini-cli];
    };
  };
}
