{lib, ...}: {
  flake.nixosModules.service-qbittorrent = {
    services.qbittorrent = {
      enable = lib.mkDefault true;
      user = lib.mkDefault "root";
      webuiPort = lib.mkDefault 8080;
      torrentingPort = lib.mkDefault 61640;
      serverConfig = {
        LegalNotice.Accepted = lib.mkDefault true;
        Preferences = {
          WebUI = {
            Username = lib.mkDefault "user";
            Password_PBKDF2 = lib.mkDefault "@ByteArray(+rg1RhvMUar4o8t10fvXgw==:EezNM70+FoG2R88DGjP9STsVT4LrjoySmyRmS6W2sWJRtQvHsE9sydYMJwSeQ+rs7HWwsg5+syC2KcfzzB0i+Q==)";
          };
          General.Locale = lib.mkDefault "en";
        };
      };
    };
  };
}
