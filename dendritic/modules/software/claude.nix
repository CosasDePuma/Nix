{
  inputs,
  lib,
  ...
}: {
  flake = {
    darwinModules.software-claude = {pkgs, ...}: {
      environment.systemPackages = [inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.claude-code];
      homebrew.casks = ["claude"];
    };

    homeManagerModules.software-claude = {pkgs, ...}: {
      imports = with inputs.self.homeManagerModules; [software-mcp];
      config.programs.claude-code = {
        enable = lib.mkDefault true;
        package = lib.mkDefault inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.claude-code;
        enableMcpIntegration = lib.mkDefault true;
        settings.includeCoAuthoredBy = lib.mkDefault false;
      };
    };

    nixosModules.software-claude = {pkgs, ...}: {
      environment.systemPackages = [inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.claude-code];
    };
  };
}
