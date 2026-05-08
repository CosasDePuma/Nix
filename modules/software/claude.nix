{ lib, pkgs, ... }:
{
  flake.modules = {
    darwin.claude-software = {
      homebrew = {
        casks = [
          "claude"
          "claude-code"
        ];
      };
    };

    nixos.claude-software = {
      environment.systemPackages = with pkgs; [
        claude-code
      ];
    };
  };
}