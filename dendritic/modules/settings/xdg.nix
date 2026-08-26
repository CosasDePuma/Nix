{lib, ...}: {
  flake = {
    homeManagerModules.settings-xdg = {config, ...}: {
      xdg.userDirs = {
        enable = lib.mkDefault true;
        createDirectories = lib.mkDefault false;
        desktop = lib.mkDefault null;
        documents = lib.mkDefault "${config.home.homeDirectory}/Documents";
        download = lib.mkDefault "${config.home.homeDirectory}/Downloads";
        music = lib.mkDefault null;
        pictures = lib.mkDefault null;
        publicShare = lib.mkDefault null;
        templates = lib.mkDefault null;
        videos = lib.mkDefault null;
      };
    };
  };
}
