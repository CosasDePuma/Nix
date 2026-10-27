{inputs, ...}: {
  flake = {
    darwinModules.software-pi = {
      homebrew.brews = ["pi-coding-agent"];
    };

    homeManagerModules.software-pi = {
      config,
      lib,
      pkgs,
      ...
    }: let
      cfg = config.programs.pi-coding-agent;
      inherit (config.programs) mcp;
    in {
      imports = with inputs.self.homeManagerModules; [software-mcp];
      config = {
        programs.pi-coding-agent = {
          enable = lib.mkDefault true;
          # Pi writes its own settings (`pi config`), so keep settings.json writable.
          mutableSettings = lib.mkDefault true;
          settings = {
            enableInstallTelemetry = lib.mkForce false;
            packages = [
              "npm:pi-blackhole"
              # "npm:pi-hermes-memory"
            ];
          };
        };

        # Pi's built-in MCP extension reads mcp.json from its config directory,
        # which `pi mcp add` and `/login` also write, so merge the shared servers
        # into it instead of linking a read-only file.
        home.activation.piMcpServers = lib.mkIf (cfg.enable && mcp.enable && mcp.servers != {}) (
          lib.hm.dag.entryAfter ["linkGeneration"] (
            lib.hm.generators.mkImpureConfigMerger {
              inherit pkgs;
              format = "json";
              empty = "{}";
              path = "${cfg.configDir}/mcp.json";
              staticSettings = (pkgs.formats.json {}).generate "pi-mcp.json" {mcpServers = mcp.servers;};
              jqOperation = "$dynamic * $static";
            }
          )
        );
      };
    };

    nixosModules.software-pi = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [pi-coding-agent];
    };
  };
}
