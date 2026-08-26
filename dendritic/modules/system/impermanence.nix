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
      hideMounts = lib.mkDefault true;
      directories =
        [
          "/var/log"
          "/var/lib/nixos"
          "/var/lib/systemd"
          "/etc/NetworkManager/system-connections"
          "/etc/ssh"
        ]
        ++ lib.optionals (config.virtualisation.libvirtd.enable or false) ["/var/lib/libvirt"]
        ++ lib.optionals (config.virtualisation.docker.enable or false) ["/var/lib/docker"]
        ++ lib.optionals (config.virtualisation.podman.enable or false) ["/var/lib/containers"]
        ++ lib.optionals (config.services.ollama.enable or false) ["/var/lib/ollama"];
      files = [
        "/etc/machine-id"
      ];
    };
  };
}
