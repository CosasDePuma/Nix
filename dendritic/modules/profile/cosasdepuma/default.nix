{lib, ...}: {
  flake = {
    homeManagerModules.profile-cosasdepuma = {
      programs.git.settings.user = {
        name = lib.mkDefault "Kike Fontán";
        email = lib.mkDefault "26680023+CosasDePuma@users.noreply.github.com";
      };
      home.file.".ssh/config.d/homelab".source = ./.ssh/homelab.config;
      nix.registry.homelab.to = {
        type = "github";
        owner = "cosasdepuma";
        repo = "nix";
      };
    };
  };
}
