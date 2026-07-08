{lib, ...}: {
  flake.homeManagerModules.software-mcp = {pkgs, ...}: {
    programs.mcp = {
      enable = lib.mkDefault true;
      servers = lib.mkDefault {
        "context7".url = "https://mcp.context7.com/mcp";
        "playwright" = {
          command = "${pkgs.playwright-mcp}/bin/mcp-server-playwright";
          args = [
            "--headless"
            "--isolated"
          ];
        };
      };
    };
  };
}
