{lib, ...}: let
  sshClientConfig = darwin:
    lib.mkDefault (lib.concatStringsSep "\n" ([
        (lib.optionalString darwin "Include ~/.orbstack/ssh/config")
        "Include ~/.ssh/config.d/*"
        ""
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
    darwinModules.software-ssh = {pkgs, ...}: {
      environment.systemPackages = [pkgs.sshpass];
    };

    homeManagerModules.software-ssh = {pkgs, ...}: {
      services.ssh-agent.enable = lib.mkDefault true;
      home.file.".ssh/config".text = sshClientConfig pkgs.stdenv.hostPlatform.isDarwin;
      home.packages = [pkgs.sshpass];
    };

    nixosModules.software-ssh = {pkgs, ...}: {
      environment.systemPackages = [pkgs.sshpass];
    };
  };
}
