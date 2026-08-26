_: let
  colors = builtins.fromTOML (builtins.readFile ./colors.toml);
in {
  flake.homeManagerModules.themes-osakajade = import ../_/default.nix {
    inherit colors;
    colorsFile = ./colors.toml;
    backgroundsDir = ./backgrounds;
  };
}
