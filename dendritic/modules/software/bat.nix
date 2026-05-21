{lib, ...}: let
  batconfig = {
    color = lib.mkDefault "always";
    paging = lib.mkDefault "never";
    style = lib.mkDefault "plain";
  };
in {
  flake = {
    darwinModules.software-bat = {
      homebrew.brews = ["bat"];
    };

    homeManagerModules.software-bat = {pkgs, ...}: {
      programs = {
        bat = {
          enable = lib.mkDefault true;
          config = lib.mkDefault batconfig;
        };
        zsh = {
          shellAliases."cat" = lib.mkDefault "${pkgs.bat}/bin/bat";
          shellGlobalAliases = {
            "-h" = lib.mkDefault "-h 2>&1 | ${pkgs.bat}/bin/bat --language=help";
            "--help" = lib.mkDefault "--help 2>&1 | ${pkgs.bat}/bin/bat --language=help";
          };
        };
      };
    };

    nixosModules.software-bat = {pkgs, ...}: {
      programs = {
        bat = {
          enable = lib.mkDefault true;
          settings = lib.mkDefault batconfig;
        };
        zsh.shellAliases."cat" = lib.mkDefault "${pkgs.bat}/bin/bat";
      };
    };
  };
}
