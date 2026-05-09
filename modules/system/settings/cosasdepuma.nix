_: let
  git = {
    email = "26680023+CosasDePuma@users.noreply.github.com";
    name = "Kike Fontán";
  };
in {
  flake.modules = {
    homeManager.cosasdepuma-settings = {
      programs.git.settings.user = git;
    };

    nixos.cosasdepuma-settings = {
      programs.git.config.user = git;
    };
  };
}
