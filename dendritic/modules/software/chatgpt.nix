{
  inputs,
  lib,
  ...
}: {
  flake = {
    darwinModules.software-chatgpt = {
      homebrew.casks = [
        "chatgpt"
        "codex"
      ];
    };

    homeManagerModules.software-chatgpt = {...}: {
      imports = with inputs.self.homeManagerModules; [software-mcp];
      config.programs.codex = {
        enable = lib.mkDefault true;
        enableMcpIntegration = lib.mkDefault true;
      };
    };

    nixosModules.software-chatgpt = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [codex];
    };
  };
}
