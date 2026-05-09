{lib, ...}: let
  batconfig = {
    color = lib.mkDefault "always";
    paging = lib.mkDefault "never";
    style = lib.mkDefault "plain";
  };
in {
  flake.modules = {
    darwin.bat-software = {
      homebrew.brews = ["bat"];
    };

    homeManager.bat-software = {pkgs, ...}: {
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

    nixos.bat-software = {pkgs, ...}: {
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
