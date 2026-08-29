{lib, ...}: {
  flake.darwinModules.software-cleanmymac = {
    homebrew.masApps."cleanmymac" = lib.mkDefault 1339170533;
  };
}
