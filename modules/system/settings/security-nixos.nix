{
  flake.modules.nixos.security = {
    security = {
      pam = {
        sshAgentAuth.enable = true;
        services."sudo".sshAgentAuth = true;
      };
      sudo-rs = {
        enable = true;
        execWheelOnly = true;
      };
    };
  };
}
