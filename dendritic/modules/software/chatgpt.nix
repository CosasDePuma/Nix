{
  inputs,
  lib,
  ...
}: {
  flake = {
    darwinModules.software-chatgpt = {pkgs, ...}: {
      environment.systemPackages = [inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.codex];
      homebrew.casks = ["chatgpt"];
    };

    homeManagerModules.software-chatgpt = {pkgs, ...}: {
      imports = with inputs.self.homeManagerModules; [software-mcp];
      config.programs.codex = {
        enable = lib.mkDefault true;
        package = lib.mkDefault inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.codex;
        enableMcpIntegration = lib.mkDefault true;
        # Codex persists trusted projects into config.toml, so it must stay writable.
        mutableSettings = lib.mkDefault true;
      };
    };

    nixosModules.software-chatgpt = {pkgs, ...}: {
      environment.systemPackages = [inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.codex];
    };
  };
}
