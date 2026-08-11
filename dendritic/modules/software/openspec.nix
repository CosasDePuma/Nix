{lib, ...}: {
  flake = {
    darwinModules.software-openspec = {
      homebrew.brews = ["openspec"];
      environment.variables."OPENSPEC_TELEMETRY" = lib.mkDefault "0";
    };

    homeManagerModules.software-openspec = {pkgs, ...}: {
      home = {
        packages = [pkgs.openspec];
        sessionVariables."OPENSPEC_TELEMETRY" = lib.mkDefault "0";
      };
    };

    nixosModules.software-openspec = {pkgs, ...}: {
      environment = {
        systemPackages = [pkgs.openspec];
        sessionVariables."OPENSPEC_TELEMETRY" = lib.mkDefault "0";
      };
    };
  };
}
