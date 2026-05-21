_: {
  flake.modules.nixos.catppuccin-software = {
    home-manager.users.rabbit = {
      catppuccin = {
        enable = true;
        flavor = "macchiato";
        vscode.profiles = {
          "default" = {};
          "python" = {};
        };
      };
    };
  };
}
