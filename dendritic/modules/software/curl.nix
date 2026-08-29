{lib, ...}: let
  curlrc = darwin:
    lib.mkDefault (lib.concatStringsSep "\n" [
      "# Wait before timing out."
      "connect-timeout = 60"
      "max-time = 0"
      ""
      "# Automatically set the previous URL as referer when following a redirect."
      "referer = \";auto\""
      ""
      "# Follow HTTP redirects by default."
      "location"
      ""
      "# Retry a few times when a request fails."
      "retry = 5"
      "retry-delay = 5"
      "retry-connrefused"
      ""
      "# Resume partially downloaded files when possible."
      "continue-at = -"
      ""
      "# Enable HTTP compression when supported by the server."
      "compressed"
      ""
      "# Show a consistent progress bar."
      "progress-bar"
      ""
      "# Use the system CA certificates."
      (
        if darwin
        then "cacert = /etc/ssl/cert.pem"
        else "capath = /etc/ssl/certs"
      )
      ""
      "# Disguise as IE 9 on Windows 7."
      "user-agent = \"Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; Trident/5.0)\""
    ]);
in {
  flake = {
    darwinModules.software-curl = {
      homebrew.brews = ["curl"];
      environment.etc."curlrc".text = curlrc true;
    };

    homeManagerModules.software-curl = {pkgs, ...}: {
      home.packages = with pkgs; [curl];
      home.file.".curlrc".text = curlrc pkgs.stdenv.hostPlatform.isDarwin;
    };

    nixosModules.software-curl = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [curl];
      environment.etc."curlrc".text = curlrc false;
    };
  };
}
