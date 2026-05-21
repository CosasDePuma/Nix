{lib, ...}: let
  git = {
    email = lib.mkDefault "26680023+CosasDePuma@users.noreply.github.com";
    name = lib.mkDefault "Kike Fontán";
  };
in {
  flake = {
    homeManagerModules.cosasdepuma-settings = {
      programs.git.settings.user = git;
    };

    nixosModules.cosasdepuma-settings = {
      programs.git.config.user = git;
    };
  };
}
