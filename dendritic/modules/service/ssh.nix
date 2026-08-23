{lib, ...}: let
  ciphers = [
    "chacha20-poly1305@openssh.com"
    "aes256-gcm@openssh.com"
    "aes128-gcm@openssh.com"
    "aes256-ctr"
    "aes192-ctr"
    "aes128-ctr"
  ];
  kex = [
    "mlkem768x25519-sha256"
    "sntrup761x25519-sha512"
    "sntrup761x25519-sha512@openssh.com"
  ];
  macs = [
    "hmac-sha2-512-etm@openssh.com"
    "hmac-sha2-256-etm@openssh.com"
    "umac-128-etm@openssh.com"
  ];
  sshHardening = ''
    Ciphers ${lib.concatStringsSep "," ciphers}
    KexAlgorithms ${lib.concatStringsSep "," kex}
    MACs ${lib.concatStringsSep "," macs}
    AuthorizedPrincipalsFile none
    ChallengeResponseAuthentication no
    ClientAliveInterval 300
    GatewayPorts no
    IgnoreRhosts yes
    KbdInteractiveAuthentication no
    LogLevel VERBOSE
    LoginGraceTime 30
    MaxAuthTries 3
    MaxSessions 5
    MaxStartups 10:30:100
    PerSourceMaxStartups 1
    PasswordAuthentication no
    PermitEmptyPasswords no
    PermitRootLogin no
    PrintMotd no
    StrictModes yes
    UseDns no
    X11Forwarding no
  '';
in {
  flake = {
    darwinModules.service-ssh = {config, ...}: {
      services.openssh = {
        enable = lib.mkDefault true;
        extraConfig =
          sshHardening
          + lib.optionalString (config.system.primaryUser != null) "\nAllowUsers ${config.system.primaryUser}";
      };
    };

    nixosModules.service-ssh = {
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
          Ciphers = lib.mkDefault ciphers;
          ClientAliveInterval = lib.mkDefault 300;
          GatewayPorts = lib.mkDefault "no";
          IgnoreRhosts = lib.mkDefault true;
          KbdInteractiveAuthentication = lib.mkDefault false;
          KexAlgorithms = lib.mkDefault kex;
          LogLevel = lib.mkDefault "VERBOSE";
          LoginGraceTime = lib.mkDefault "30";
          Macs = lib.mkDefault macs;
          MaxAuthTries = lib.mkDefault 3;
          MaxSessions = lib.mkDefault 5;
          MaxStartups = lib.mkDefault "10:30:100";
          PerSourceMaxStartups = lib.mkDefault "1";
          PasswordAuthentication = lib.mkDefault false;
          PermitEmptyPasswords = lib.mkDefault false;
          PermitRootLogin = lib.mkDefault "no";
          PrintMotd = lib.mkDefault false;
          StrictModes = lib.mkDefault true;
          UseDns = lib.mkDefault false;
          UsePAM = lib.mkDefault true;
          X11Forwarding = lib.mkDefault false;
          AllowUsers = lib.mkDefault (
            let
              allowed = lib.attrsets.mapAttrsToList (name: _: name) (
                lib.attrsets.filterAttrs (_: v: builtins.elem "sshusers" (v.extraGroups or [])) config.users.users
              );
            in
              if allowed == []
              then null
              else allowed
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
  };
}
