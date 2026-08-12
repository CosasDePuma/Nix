{
  inputs,
  lib,
  ...
}: {
  flake.homeManagerModules.profile-cosasdepuma = {config, ...}: let
    home = config.home.homeDirectory;
  in {
    imports = [inputs.agenix.homeManagerModules.default];

    programs.git.settings.user = {
      name = lib.mkDefault "Kike Fontán";
      email = lib.mkDefault "26680023+CosasDePuma@users.noreply.github.com";
      signingkey = lib.mkDefault "~/.ssh/id_ed25519.pub";
    };

    nix.registry.homelab.to = {
      type = "github";
      owner = "cosasdepuma";
      repo = "nix";
    };

    age.secrets = {
      "ssh-keys-homelab" = {
        file = ./.ssh/keys/homelab.age;
        path = "${home}/.ssh/keys/homelab";
        mode = "0400";
      };
      "ssh-keys-pumita" = {
        file = ./.ssh/keys/pumita.age;
        path = "${home}/.ssh/keys/pumita";
        mode = "0400";
      };
    };

    home.file = {
      ".ssh/config.d/homelab".source = ./.ssh/config.d/homelab;
      ".ssh/keys/homelab.pub".text = builtins.readFile ./.ssh/keys/homelab.pub;
      ".ssh/keys/pumita.pub".text = builtins.readFile ./.ssh/keys/pumita.pub;
      ".ssh/id_ed25519".source = config.lib.file.mkOutOfStoreSymlink "${home}/.ssh/keys/pumita";
      ".ssh/id_ed25519.pub".source = config.lib.file.mkOutOfStoreSymlink "${home}/.ssh/keys/pumita.pub";
    };
  };
}
