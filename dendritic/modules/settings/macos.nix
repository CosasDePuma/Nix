{lib, ...}: {
  flake.modules.darwin.settings-macos = {
    system.defaults = {
      dock.autohide = lib.mkDefault true;
      finder = {
        CreateDesktop = lib.mkDefault false;
        ShowExternalHardDrivesOnDesktop = lib.mkDefault true;
        ShowHardDrivesOnDesktop = lib.mkDefault true;
        ShowMountedServersOnDesktop = lib.mkDefault true;
        ShowRemovableMediaOnDesktop = lib.mkDefault true;
        _FXSortFoldersFirst = lib.mkDefault true;
        AppleShowAllExtensions = lib.mkDefault true;
        AppleShowAllFiles = lib.mkDefault true;
        FXPreferredViewStyle = lib.mkDefault "clmv";
        NewWindowTarget = lib.mkDefault "Home";
        QuitMenuItem = lib.mkDefault true;
        ShowPathbar = lib.mkDefault true;
        ShowStatusBar = lib.mkDefault true;
      };
    };
  };
}
