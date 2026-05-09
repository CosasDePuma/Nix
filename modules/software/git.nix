{lib, ...}: let
  gitconfig = {
    alias.graph = lib.mkDefault "log --abbrev-commit --all --color --decorate --graph --oneline";
    color.ui = lib.mkDefault true;
    help.autocorrect = lib.mkDefault 1;
    init.defaultBranch = lib.mkDefault "main";
    log.date = lib.mkDefault "human";
    pull.ff = lib.mkDefault "only";
    push.autoSetupRemote = lib.mkDefault true;
    url."git@github.com:".insteadOf = lib.mkDefault "github:";
    user = {
      email = lib.mkDefault "26680023+CosasDePuma@users.noreply.github.com";
      name = lib.mkDefault "Kike Fontán";
    };
  };
  gitignore = [
    # keep-sorted start
    "**/*.bck"
    "**/*.db"
    "**/*.env"
    "**/*.local.*"
    "**/*.log"
    "**/*.pyc"
    "**/*.swo"
    "**/*.swp"
    "**/*.tsbuildinfo"
    "**/*~"
    "**/.DS_Store"
    "**/.cache/"
    "**/.claude/"
    "**/.desktop.ini"
    "**/.direnv/"
    "**/.env.*.local"
    "**/.env.local"
    "**/.idea/"
    "**/__pycache__/"
    "**/build/"
    "**/bun.lockb"
    "**/coverage/"
    "**/dist/*"
    "**/node_modules/"
    "**/result/"
    "**/temp/"
    "**/tmp/"
    # keep-sorted end
  ];
in {
  flake.modules = {
    darwin.git-software = {
      homebrew.brews = ["git"];
    };

    homeManager.git-software = {
      programs.git = {
        enable = lib.mkDefault true;
        ignores = lib.mkDefault gitignore;
        settings = lib.mkDefault gitconfig;
      };
    };

    nixos.git-software = {
      programs.git = {
        enable = lib.mkDefault true;
        config = lib.mkDefault gitconfig;
        ignores = lib.mkDefault gitignore;
      };
    };
  };
}
