{lib, ...}: let
  sshClientConfig = darwin:
    lib.mkDefault (lib.concatStringsSep "\n" ([
        (lib.optionalString darwin "Include ~/.orbstack/ssh/config")
        "Host *"
        "  AddKeysToAgent        yes"
        "  IdentitiesOnly        yes"
        "  ServerAliveInterval   60"
        "  ServerAliveCountMax   3"
        "  StrictHostKeyChecking no"
        "  UserKnownHostsFile    /dev/null"
      ]
      ++ lib.optional darwin "  UseKeychain           yes"));
in {
  flake = {
    darwinModules.software-ssh-client = {
      environment.etc."ssh/ssh_config.d/99-user-base.conf".text = sshClientConfig true;
    };

    homeManagerModules.software-ssh-client = {pkgs, ...}: {
      home.file.".ssh/config".text = sshClientConfig pkgs.stdenv.hostPlatform.isDarwin;
    };

    nixosModules.software-ssh-client = {
      programs.ssh.extraConfig = sshClientConfig false;
    };
  };
}
