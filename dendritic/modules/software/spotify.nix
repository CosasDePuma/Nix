_: {
  flake.modules = {
    darwin.software-spotify = {
      homebrew.casks = ["spotify"];
    };

    homeManager.software-spotify = {pkgs, ...}: {
      home.packages = with pkgs; [
        spotify
      ];
    };

    nixos.software-spotify = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [
        spotify
      ];
    };
  };
}
