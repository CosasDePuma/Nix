{
  inputs,
  lib,
  ...
}: {
  flake.nixosModules.system-impermanence = {config, ...}: {
    imports = [
      inputs.impermanence.nixosModules.impermanence
    ];

    environment.persistence."/nix/persist" = {
      hideMounts = true;
      directories =
        [
          "/var/log"
          "/var/lib/nixos"
          "/var/lib/systemd"
          "/etc/NetworkManager/system-connections"
          "/etc/ssh"
        ]
        ++ lib.optional config.virtualisation.libvirtd.enable "/var/lib/libvirt";
      files = [
        "/etc/machine-id"
      ];
    };
  };
}
