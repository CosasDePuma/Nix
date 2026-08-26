_: let
  colors = builtins.fromTOML (builtins.readFile ./colors.toml);
in {
  flake.homeManagerModules.themes-everforest = import ../_/default.nix {
    inherit colors;
    colorsFile = ./colors.toml;
    backgroundsDir = ./backgrounds;
    vscodeTheme = "Everforest Pro Dark";
    vscodeExtension = pkgs:
      pkgs.vscode-utils.extensionFromVscodeMarketplace {
        name = "everforest-pro";
        publisher = "andreilucaci";
        version = "2.0.0";
        sha256 = "0s6vy9ryfwnpi88rvgxmrwsynhw3zwwks8h404bhn55xwz610378";
      };
  };
}
