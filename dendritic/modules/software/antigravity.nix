{
  inputs,
  lib,
  ...
}: {
  flake = {
    darwinModules.software-antigravity = {pkgs, ...}: {
      environment.systemPackages = [inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.antigravity-cli];
      homebrew.casks = ["google-gemini"];
    };

    homeManagerModules.software-antigravity = {pkgs, ...}: {
      imports = with inputs.self.homeManagerModules; [software-mcp];
      config.programs.antigravity-cli = {
        enable = lib.mkDefault true;
        package = lib.mkDefault inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.antigravity-cli;
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
      environment.systemPackages = [inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.antigravity-cli];
    };
  };
}
