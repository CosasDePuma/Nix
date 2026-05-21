{lib, ...}: {
  flake = {
    darwinModules.software-sudo = {
      security.pam.services.sudo_local = {
        touchIdAuth = lib.mkDefault true;
        reattach = lib.mkDefault true;
      };
    };

    nixosModules.software-sudo = {config, ...}: {
      security = {
        pam.services."sudo".sshAgentAuth = lib.mkDefault config.security.pam.sshAgentAuth.enable;
        sudo-rs = {
          enable = lib.mkDefault true;
          execWheelOnly = lib.mkDefault true;
        };
      };
    };
  };
}
