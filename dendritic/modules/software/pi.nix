{lib, ...}: {
  flake = {
    darwinModules.software-pi = {
      homebrew.brews = ["pi-coding-agent"];
    };

    homeManagerModules.software-pi = {
      programs.pi-coding-agent = {
        enable = lib.mkDefault true;
        settings = {
          enableInstallTelemetry = lib.mkForce false;
          packages = [
            "npm:pi-blackhole"
            # "npm:pi-hermes-memory"
            "npm:pi-mcp-adapter"
          ];
        };
      };
    };

    nixosModules.software-pi = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [pi-coding-agent];
    };
  };
}
