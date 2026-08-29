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
        ]
        ++ lib.optionals (config.virtualisation.libvirtd.enable or false) ["/var/lib/libvirt"]
        ++ lib.optionals (config.virtualisation.docker.enable or false) ["/var/lib/docker"]
        ++ lib.optionals (config.virtualisation.podman.enable or false) ["/var/lib/containers"]
        ++ lib.optionals (config.services.ollama.enable or false) ["/var/lib/ollama"]
        ++ lib.optionals (config.services.headscale.enable or false) ["/var/lib/headscale"]
        ++ lib.optionals (config.services.tailscale.enable or false) ["/var/lib/tailscale"];
      # Host keys only, not the whole "/etc/ssh" directory: NixOS populates
      # /etc/ssh with symlinks into the store (sshd_config, ssh_config,
      # authorized_keys.d, ...), and persisting the directory wholesale
      # bind-mounts over them, hiding every one of those symlinks behind
      # whatever the persisted dir actually contains -- sshd then fails to
      # find sshd_config at all. Persisting only the key files leaves the
      # rest of /etc/ssh as NixOS put it.
      files = [
        "/etc/machine-id"
        "/etc/ssh/ssh_host_ed25519_key"
        "/etc/ssh/ssh_host_ed25519_key.pub"
        "/etc/ssh/ssh_host_rsa_key"
        "/etc/ssh/ssh_host_rsa_key.pub"
      ];
    };
  };
}
