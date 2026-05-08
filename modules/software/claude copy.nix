{ lib, ... }:
{
  flake.modules = {
    darwin.gemini-software = {
      homebrew = {
        brews = [
          "gemini-cli"
        ];
        casks = [
          "google-gemini"
        ];
      };
    };

    nixos.gemini-software = {
      environment.systemPackages = with pkgs; [
        gemini-cli
      ];
    };
  };
}