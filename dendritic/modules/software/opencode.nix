{
  inputs,
  lib,
  ...
}: {
  flake = {
    darwinModules.software-opencode = {
      homebrew = {
        brews = ["opencode"];
        casks = ["opencode-desktop"];
      };
    };

    homeManagerModules.software-opencode = {pkgs, ...}: {
      imports = with inputs.self.homeManagerModules; [software-mcp];
      config = {
        home.packages = with pkgs; [opencode-desktop];
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

    nixosModules.software-opencode = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [
        opencode
        opencode-desktop
      ];
    };
  };
}
