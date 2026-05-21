{lib, ...}: let
  starshipconfig = {
    character = lib.mkDefault {
      error_symbol = "[[💩](red) ❯](peach)";
      success_symbol = "[[🦄](green) ❯](peach)";
    };
    directory = lib.mkDefault {
      format = "[$path]($style)[$read_only]($read_only_style) ";
      read_only = " 🔒";
      style = "bold lavender";
      truncate_to_repo = true;
      truncation_length = 4;
    };
    git_branch.style = "bold mauve";
    nix_shell = lib.mkDefault {
      format = "[$symbol$name]($style) ";
      style = "bold blue";
    };
    sudo.disabled = lib.mkDefault true;
  };
in {
  flake.modules = {
    darwin.software-starship = {
      homebrew.brews = ["starship"];
    };

    homeManager.software-starship = {osConfig, ...}: {
      programs.starship = {
        enable = lib.mkDefault true;
        enableBashIntegration = lib.mkDefault osConfig.programs.bash.enable;
        enableFishIntegration = lib.mkDefault osConfig.programs.fish.enable;
        enableZshIntegration = lib.mkDefault osConfig.programs.zsh.enable;
        presets = lib.mkDefault ["nerd-font-symbols"];
        settings = lib.mkDefault starshipconfig;
      };
    };

    nixos.software-starship = _: {
      programs.starship = {
        enable = lib.mkDefault true;
        presets = lib.mkDefault ["nerd-font-symbols"];
        settings = lib.mkDefault starshipconfig;
      };
    };
  };
}
