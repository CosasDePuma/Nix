{lib, ...}: {
  flake.nixosModules.network-wakeonlan = {pkgs, ...}: {
    environment.systemPackages = [pkgs.ethtool];

    # Physical ethernet NICs only (`Kind=!*` skips bridges, taps, VLANs).
    # A matching .link file replaces 99-default.link, so its naming and MAC
    # policies are carried over to leave interface names untouched.
    systemd.network.links."50-wakeonlan" = {
      matchConfig = {
        Type = "ether";
        Kind = "!*";
      };
      linkConfig = {
        NamePolicy = lib.mkDefault "keep kernel database onboard slot path";
        AlternativeNamesPolicy = lib.mkDefault "database onboard slot path";
        MACAddressPolicy = lib.mkDefault "persistent";
        WakeOnLan = lib.mkDefault "magic";
      };
    };
  };
}
