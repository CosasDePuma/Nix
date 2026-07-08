{
  inputs,
  lib,
  ...
}: {
  flake = {
    darwinModules.software-antigravity = {
      homebrew = {
        brews = ["antigravity-cli"];
        casks = ["antigravity"];
      };
    };

    homeManagerModules.software-antigravity = {
      config,
      pkgs,
      ...
    }: {
      imports = with inputs.self.homeManagerModules; [software-mcp];
      config = lib.mkMerge [
        {
          programs.antigravity-cli = {
            context.fileName = lib.mkDefault ''
              AGENTS.md
              ANTIGRAVITY.md
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

    nixosModules.software-antigravity = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [antigravity-cli];
    };
  };
}
