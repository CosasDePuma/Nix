{lib, ...}: let
  gitconfig = {
    alias = {
      aliases = "config --global --get-regexp 'alias\\.'";
      fullgraph = "log --graph --all --color --abbrev-commit --date=relative --pretty=format:'%C(red)%h%C(green)%d%C(reset)%x20%cd%C(bold blue)%x20%cn%C(reset)%C(yellow)%x20(%ce)%x20%C(cyan)%C(reset)%x20%s'";
      graph = "log --abbrev-commit --all --color --decorate --graph --oneline";
      last = "log -1 HEAD";
    };
    color = {
      ui = true;
      branch = {
        current = "green";
        local = "black dim";
        remote = "yellow";
      };
      status = {
        added = "green";
        changed = "yellow";
        untracked = "black dim";
      };
    };
    help.autocorrect = 1;
    init.defaultBranch = "main";
    log.date = "human";
    pull.ff = "only";
    push.autoSetupRemote = true;
    url."git@github.com:".insteadOf = "github:";
    url."https://github.com/".insteadOf = "github.com:";
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
