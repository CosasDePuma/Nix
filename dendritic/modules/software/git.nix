{lib, ...}: let
  gitconfig = {
    alias.graph = "log --abbrev-commit --all --color --decorate --graph --oneline";
    color.ui = true;
    help.autocorrect = 1;
    init.defaultBranch = "main";
    log.date = "human";
    pull.ff = "only";
    push.autoSetupRemote = true;
    url."git@github.com:".insteadOf = "github:";
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
  flake = {
    darwinModules.software-git = {
      homebrew.brews = ["git"];
    };

    homeManagerModules.software-git = {
      programs.git = {
        enable = lib.mkDefault true;
        ignores = lib.mkDefault gitignore;
        lfs.enable = lib.mkDefault true;
        settings = gitconfig;
        signing = {
          format = lib.mkDefault "ssh";
          signByDefault = lib.mkDefault true;
        };
      };
    };

    nixosModules.software-git = {
      environment.etc."gitignore-global".text = lib.concatStringsSep "\n" gitignore + "\n";
      programs.git = {
        enable = lib.mkDefault true;
        config =
          gitconfig
          // {
            core.excludesFile = "/etc/gitignore-global";
          };
        lfs.enable = lib.mkDefault true;
      };
    };
  };
}
