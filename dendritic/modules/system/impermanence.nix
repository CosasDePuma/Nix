{inputs, ...}: {
  flake.nixosModules.system-impermanence = {
    imports = [
      inputs.impermanence.nixosModules.impermanence
    ];

    environment.persistence."/nix/persist" = {
      hideMounts = true;
      directories = [
        "/var/log"
        "/var/lib/nixos"
        "/var/lib/systemd"
        "/etc/NetworkManager/system-connections"
        "/etc/ssh"
        "/var/lib/libvirt"
      ];
      files = [
        "/etc/machine-id"
      ];
    };
  };
}
