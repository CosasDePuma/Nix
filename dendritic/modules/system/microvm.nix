{inputs, ...}: {
  # Guest side of a microvm.nix VM: shares the host's /nix/store, hands
  # unused RAM back to the host, and keeps state on a "persist" volume the
  # same way bare-metal hosts do via system-impermanence. The volume itself
  # (size) is per machine, so each VM declares it.
  flake.nixosModules.system-microvm = {
    config,
    lib,
    ...
  }: {
    imports = with inputs.self.nixosModules; [
      network-interfaces
      system-impermanence
    ];

    microvm = {
      # Free page reporting: the guest returns memory it is not using, so
      # `mem` is a ceiling instead of a fixed reservation on the host.
      balloon = lib.mkDefault true;
      shares = [
        {
          proto = "virtiofs";
          tag = "ro-store";
          source = "/nix/store";
          mountPoint = "/nix/.ro-store";
        }
      ];
    };

    # Impermanence bind-mounts host keys and machine-id from here at boot.
    fileSystems."/nix/persist".neededForBoot = true;

    # network-dns and microvm.nix both mkDefault a hostId; settle on
    # network-dns's derivation, still below a plain host-file value.
    networking.hostId = lib.mkOverride 900 (builtins.substring 0 8 (builtins.hashString "md5" config.networking.hostName));

    # Static addressing only: a global dhcpcd stalls boot waiting for a
    # lease that never comes.
    networking.useDHCP = lib.mkDefault false;
  };
}
