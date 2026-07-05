{lib, ...}: {
  flake.nixosModules.service-ssh = {
    config,
    pkgs,
    ...
  }: {
    services.openssh.openFirewall = lib.mkDefault true;
    security.pam.sshAgentAuth.enable = lib.mkDefault true;
    services.openssh = {
      enable = lib.mkDefault true;
      allowSFTP = lib.mkDefault true;
      authorizedKeysInHomedir = lib.mkDefault false;
      ports = lib.mkDefault [64022];
      startWhenNeeded = lib.mkDefault true;
      settings = {
        AuthorizedPrincipalsFile = lib.mkDefault "none";
        ChallengeResponseAuthentication = lib.mkDefault false;
        Ciphers = lib.mkDefault [
          "chacha20-poly1305@openssh.com"
          "aes256-gcm@openssh.com"
          "aes128-gcm@openssh.com"
          "aes256-ctr"
          "aes192-ctr"
          "aes128-ctr"
        ];
        ClientAliveInterval = lib.mkDefault 300;
        GatewayPorts = lib.mkDefault "no";
        IgnoreRhosts = lib.mkDefault true;
        KbdInteractiveAuthentication = lib.mkDefault false;
        KexAlgorithms = lib.mkDefault [
          "curve25519-sha256@libssh.org"
          "diffie-hellman-group16-sha512"
          "diffie-hellman-group18-sha512"
        ];
        LogLevel = lib.mkDefault "VERBOSE";
        LoginGraceTime = lib.mkDefault "30";
        Macs = lib.mkDefault [
          "hmac-sha2-512-etm@openssh.com"
          "hmac-sha2-256-etm@openssh.com"
          "umac-128-etm@openssh.com"
        ];
        MaxAuthTries = lib.mkDefault 3;
        MaxSessions = lib.mkDefault 5;
        MaxStartups = lib.mkDefault "10:30:100";
        PasswordAuthentication = lib.mkDefault false;
        PermitEmptyPasswords = lib.mkDefault false;
        PermitRootLogin = lib.mkDefault "no";
        PrintMotd = lib.mkDefault false;
        StrictModes = lib.mkDefault true;
        UseDns = lib.mkDefault false;
        UsePAM = lib.mkDefault true;
        X11Forwarding = lib.mkDefault false;
        AllowUsers = lib.mkDefault (
          lib.attrsets.mapAttrsToList (name: _: name) (
            lib.attrsets.filterAttrs (_: v: builtins.elem "sshusers" v.extraGroups) config.users.users
          )
        );
        Banner = lib.mkDefault (builtins.toString (
          pkgs.writeText "ssh-banner" ''
            ==============================================================
            |                   AUTHORIZED ACCESS ONLY                   |
            ==============================================================
            |                                                            |
            |    WARNING: All connections are monitored and recorded.    |
            |  Disconnect IMMEDIATELY if you are not an authorized user! |
            |                                                            |
            |       *** Unauthorized access will be prosecuted ***       |
            |                                                            |
            ==============================================================
          ''
        ));
      };
    };
    users.groups."sshusers" = lib.mkDefault {};
  };
}
