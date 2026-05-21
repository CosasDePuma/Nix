{
  inputs,
  lib,
  ...
}: {
  flake.modules = {
    darwin.software-opencode = {
      homebrew = {
        brews = [
          "opencode"
        ];
        casks = [
          "opencode-desktop"
        ];
      };
    };

    homeManager.software-opencode = {pkgs, ...}: {
      imports = with inputs.self.modules.homeManager; [
        software-mcp
      ];
      config = {
        home.packages = with pkgs; [
          opencode-desktop
        ];
        programs.opencode = {
          enable = lib.mkDefault true;
          enableMcpIntegration = lib.mkDefault true;
          settings = {
            autoshare = lib.mkDefault false;
            autoupdate = lib.mkDefault true;
          };
        };
      };
    };

    nixos.software-opencode = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [
        opencode
        opencode-desktop
      ];
    };
  };
}
