{lib, ...}: {
  flake.modules = {
    darwin.settings-security = {
      security.pam.services.sudo_local = {
        touchIdAuth = lib.mkDefault true;
        reattach = lib.mkDefault true;
      };
    };

    nixos.settings-security = {
      security = {
        pam = {
          sshAgentAuth.enable = lib.mkDefault true;
          services."sudo".sshAgentAuth = lib.mkDefault true;
        };
        sudo-rs = {
          enable = lib.mkDefault true;
          execWheelOnly = lib.mkDefault true;
        };
      };
    };
  };
}
