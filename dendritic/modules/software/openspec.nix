{
  inputs,
  lib,
  ...
}: {
  flake = {
    darwinModules.software-openspec = {pkgs, ...}: {
      environment.systemPackages = [inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.openspec];
      environment.variables."OPENSPEC_TELEMETRY" = lib.mkDefault "0";
    };

    homeManagerModules.software-openspec = {pkgs, ...}: {
      home = {
        packages = [inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.openspec];
        sessionVariables."OPENSPEC_TELEMETRY" = lib.mkDefault "0";
      };
    };

    nixosModules.software-openspec = {pkgs, ...}: {
      environment = {
        systemPackages = [inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.openspec];
        sessionVariables."OPENSPEC_TELEMETRY" = lib.mkDefault "0";
      };
    };
  };
}
