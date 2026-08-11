{lib, ...}: {
  flake.homeManagerModules.software-mcp = {pkgs, ...}: {
    # Explicit key so repeated imports (claude/opencode/antigravity all
    # pull this in) dedupe instead of each contributing its own copy of
    # list-typed options like `args`, which the module system concatenates.
    key = "software-mcp";
    programs.mcp = {
      enable = lib.mkDefault true;
      servers = lib.mkDefault {
        "context7".url = "https://mcp.context7.com/mcp";
        "playwright" = {
          command = "${pkgs.playwright-mcp}/bin/playwright-mcp";
          args = [
            "--headless"
            "--isolated"
          ];
        };
      };
    };
  };
}
