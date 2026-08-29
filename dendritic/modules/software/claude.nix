{
  inputs,
  lib,
  ...
}: {
  flake = {
    darwinModules.software-claude = {
      homebrew.casks = [
        "claude"
        "claude-code"
      ];
    };

    homeManagerModules.software-claude = {...}: {
      imports = with inputs.self.homeManagerModules; [software-mcp];
      config.programs.claude-code = {
        enable = lib.mkDefault true;
        enableMcpIntegration = lib.mkDefault true;
      };
    };

    nixosModules.software-claude = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [claude-code];
    };
  };
}
