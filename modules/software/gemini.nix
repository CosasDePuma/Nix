{lib, ...}: {
  flake.modules = {
    darwin.gemini-software = {
      homebrew = {
        brews = [
          "gemini-cli"
        ];
        casks = [
          "google-gemini"
        ];
      };
    };

    homeManager.gemini-software = {
      config,
      pkgs,
      ...
    }:
      lib.mkMerge [
        {
          programs = {
            gemini-cli = {
              context.fileName = [
                "AGENTS.md"
                "CLAUDE.md"
                "CONTEXT.md"
                "GEMINI.md"
              ];
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

            mcp = {
              enable = lib.mkDefault true;
              servers = lib.mkDefault {
                "context7".url = "https://mcp.context7.com/mcp";
                "playwright" = {
                  command = "${pkgs.playwright-mcp}/bin/mcp-server-playwright";
                  args = [
                    "--headless"
                    "--isolated"
                  ];
                };
              };
            };
          };
        }
        (lib.mkIf config.programs.vscode.enable {
          my.vscode-extraExtensions = with pkgs.vscode-extensions; [Google.gemini-cli-vscode-ide-companion];
        })
      ];

    nixos.gemini-software = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [
        gemini-cli
      ];
    };
  };
}
