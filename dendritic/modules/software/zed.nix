{
  inputs,
  lib,
  ...
}: {
  flake = {
    darwinModules.software-zed = {
      homebrew.casks = ["zed"];
    };

    homeManagerModules.software-zed = {config, ...}: {
      imports = with inputs.self.homeManagerModules; [software-mcp];
      config.programs.zed-editor = {
        enable = lib.mkDefault true;
        enableMcpIntegration = lib.mkDefault true;
        extensions = ["nix"];
        userSettings = {
          agent_servers = lib.mkMerge [
            (lib.optionalAttrs (config.programs.antigravity-cli.enable or false) {
              "antigravity-acp".type = "registry";
            })
            (lib.optionalAttrs (config.programs.claude-code.enable or false) {
              "claude-acp".type = "registry";
            })
            (lib.optionalAttrs (config.programs.opencode.enable or false) {
              "opencode".type = "registry";
            })
            (lib.optionalAttrs (config.programs.pi-coding-agent.enable or false) {
              "pi-acp".type = "registry";
            })
          ];
        };
      };
    };

    nixosModules.software-zed = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [zed-editor];
    };
  };
}
