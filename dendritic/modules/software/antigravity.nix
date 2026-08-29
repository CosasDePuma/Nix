{
  inputs,
  lib,
  ...
}: {
  flake = {
    darwinModules.software-antigravity = {
      homebrew.casks = [
        "antigravity-cli"
        "google-gemini"
      ];
    };

    homeManagerModules.software-antigravity = {...}: {
      imports = with inputs.self.homeManagerModules; [software-mcp];
      config.programs.antigravity-cli = {
        enable = lib.mkDefault true;
        enableMcpIntegration = lib.mkDefault true;
        settings = {
          context.fileName = lib.mkDefault [
            "AGENTS.md"
            "CLAUDE.md"
            "CONTEXT.md"
            "GEMINI.md"
          ];
          ide.enable = lib.mkDefault true;
          general = {
            preferredEditor = lib.mkDefault "code";
            previewFeatures = lib.mkDefault true;
          };
          privacy.usageStatisticsEnabled = lib.mkDefault false;
        };
      };
    };

    nixosModules.software-antigravity = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [antigravity-cli];
    };
  };
}
