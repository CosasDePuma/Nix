{lib, ...}: {
  options.flake.factory = lib.mkOption {
    type = lib.types.attrsOf lib.types.unspecified;
    default = {};
  };

  config.flake.factory.homelab-user = {
    name,
    description,
    home,
    authorizedKeysFile,
  }: {lib, ...}: {
    users.users.${name} = {
      isNormalUser = true;
      inherit description home;
      uid = 1000;
      group = "users";
      useDefaultShell = true;
      initialPassword = null;
      extraGroups = [
        "wheel"
        "sshuser"
      ];
      openssh.authorizedKeys.keys = lib.strings.splitString "\n" (builtins.readFile authorizedKeysFile);
    };
  };
}
