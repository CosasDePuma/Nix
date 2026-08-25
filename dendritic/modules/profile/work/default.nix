{inputs, ...}: {
  flake.homeManagerModules.profile-work = {
    config,
    lib,
    ...
  }: let
    decode = value: lib.concatStrings (lib.reverseList (lib.stringToCharacters value));
  in {
    imports = [inputs.agenix.homeManagerModules.default];

    age.secrets = {
      "ssh-keys-work" = {
        file = ./.ssh/keys/work.age;
        path = "${config.home.homeDirectory}/.ssh/keys/work";
        mode = "0400";
      };
      "ssh-config-work" = {
        file = ./.ssh/config.d/work.age;
        path = "${config.home.homeDirectory}/.ssh/config.d/work";
        mode = "0600";
      };
    };

    home.file = {
      ".ssh/keys/work.pub".text = builtins.readFile ./.ssh/keys/work.pub;
    };

    programs = {
      opencode.settings.plugin = [
        (decode "edocnepo/nigulp#tig.knil.texa/NNIBYCLOIBIC/667:moc.atadttn.laeme.hss-tig@tig//:hss+tig")
      ];
      pi-coding-agent.settings.packages = [
        (decode "ip/nigulp@tig.knil.texa/NNIBYCLOIBIC/667:moc.atadttn.laeme.hss-tig@tig//:hss")
      ];
    };
  };
}
