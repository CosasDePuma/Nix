{lib, ...}: {
  flake = {
    darwinModules.network-dns = {
      networking = {
        dns = lib.mkDefault [
          "1.1.1.1"
          "8.8.8.8"
        ];
        search = lib.mkDefault ["local"];
      };
    };

    nixosModules.network-dns = {config, ...}: {
      networking = {
        domain = lib.mkDefault "local";
        hostId = lib.mkDefault (builtins.substring 0 8 (builtins.hashString "md5" config.networking.hostName));
        search = lib.mkDefault ["local"];
        nameservers = lib.mkDefault [
          "1.1.1.1"
          "8.8.8.8"
        ];
      };
    };
  };
}
