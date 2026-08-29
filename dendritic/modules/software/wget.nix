{lib, ...}: let
  wgetrc = darwin:
    lib.mkDefault (lib.concatStringsSep "\n" [
      "# Add extensions to files based on MIME."
      "adjust_extension = on"
      ""
      "# Use the system CA certificates directory."
      (
        if darwin
        then "ca_directory = /etc/ssl/cert.pem"
        else "ca_directory = /etc/ssl/certs"
      )
      ""
      "# Enable HTTP compression when supported by the server."
      "compression = auto"
      ""
      "# Resume partially downloaded files."
      "continue = on"
      ""
      "# Avoid HSTS cache."
      "hsts-file = /dev/null"
      ""
      "# Show a consistent progress bar even in non-interactive shells."
      "progress = bar:force"
      "show_progress = on"
      ""
      "# Ignore 'robots.txt' and '<meta name=robots content=nofollow>'."
      "robots = off"
      ""
      "# Wait before timing out."
      "timeout = 60"
      "dns_timeout = 30"
      "connect_timeout = 30"
      "read_timeout = 60"
      ""
      "# Use timestamps to avoid re-downloading unchanged files."
      "timestamping = on"
      ""
      "# Retry a few times when a download fails."
      "tries = 5"
      "waitretry = 5"
      "retry_connrefused = on"
      ""
      "# Disguise as IE 9 on Windows 7"
      "user_agent = Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; Trident/5.0)"
    ]);
in {
  flake = {
    darwinModules.software-wget = {
      homebrew.brews = ["wget"];
      environment.etc."wgetrc".text = wgetrc true;
    };

    homeManagerModules.software-wget = {pkgs, ...}: {
      home.packages = with pkgs; [wget];
      home.file.".wgetrc".text = wgetrc pkgs.stdenv.hostPlatform.isDarwin;
    };

    nixosModules.software-wget = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [wget];
      environment.etc."wgetrc".text = wgetrc false;
    };
  };
}
