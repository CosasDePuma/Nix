_: {
  flake.modules.nixos.quickshell-software = _: {
    home-manager.users.rabbit = {
      programs.quickshell = {
        enable = true;
        systemd.enable = true;
      };
    };
  };
}
