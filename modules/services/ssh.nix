{
  flake.modules.nixos.hardened-ssh =
    { config, lib, ... }:
    {
      networking.firewall.allowedTCPPorts = [ 64022 ];

      services.openssh = {
        enable = true;
        allowSFTP = true;
        authorizedKeysInHomedir = false;
        listenAddresses = [
          {
            addr = "0.0.0.0";
            port = 64022;
          }
        ];
        ports = [ ];
        startWhenNeeded = true;
        settings = {
          AuthorizedPrincipalsFile = "none";
          ChallengeResponseAuthentication = false;
          Ciphers = [
            "chacha20-poly1305@openssh.com"
            "aes256-gcm@openssh.com"
            "aes128-gcm@openssh.com"
            "aes256-ctr"
            "aes192-ctr"
            "aes128-ctr"
          ];
          ClientAliveInterval = 300;
          GatewayPorts = "no";
          IgnoreRhosts = true;
          KbdInteractiveAuthentication = false;
          KexAlgorithms = [
            "curve25519-sha256@libssh.org"
            "diffie-hellman-group16-sha512"
            "diffie-hellman-group18-sha512"
          ];
          LogLevel = "VERBOSE";
          LoginGraceTime = "30";
          Macs = [
            "hmac-sha2-512-etm@openssh.com"
            "hmac-sha2-256-etm@openssh.com"
            "umac-128-etm@openssh.com"
          ];
          MaxAuthTries = 3;
          MaxSessions = 5;
          MaxStartups = "10:30:100";
          PasswordAuthentication = false;
          PermitEmptyPasswords = false;
          PermitRootLogin = "no";
          PrintMotd = false;
          StrictModes = true;
          UseDns = false;
          UsePAM = true;
          X11Forwarding = false;
          AllowUsers = lib.attrsets.mapAttrsToList (name: _: name) (
            lib.attrsets.filterAttrs (_: v: builtins.elem "sshuser" v.extraGroups) config.users.users
          );
        };
      };
    };
}
