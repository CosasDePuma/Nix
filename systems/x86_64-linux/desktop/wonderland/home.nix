{
  config ? throw "not imported as module",
  lib ? throw "not imported as module",
  pkgs ? throw "not imported as module",
  stateVersion ? "25.05",
  username,
  ...
}:
rec {
  # ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  # ┃               Home Manager                ┃
  # ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

  home = {
    inherit username stateVersion;
    homeDirectory = "/home/${username}";
  };

  # ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  # ┃                 Programs                  ┃
  # ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

  programs = {
    # --- bat
    bat = {
      enable = true;
      config = {
        color = "always";
        paging = "never";
        style = "plain";
      };
    };

    # --- claude
    claude-code = {
      enable = true;
      enableMcpIntegration = true;
    };

    # --- direnv
    direnv = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
      silent = true;
    };

    # --- ghostty
    ghostty = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      settings = {
        font-family = "FiraCode Nerd Font Mono";
        font-feature = "+liga";
        font-size = 15;
        font-thicken = true;
        term = "xterm-256color";
        window-padding-x = 20;
        window-padding-y = 10;
      };
    };

    # --- git
    git = {
      enable = true;
      ignores = [
        "**/*~"
        "**/*.bck"
        "**/*.env"
        "**/*.local.*"
        "**/*.pyc"
        "**/*.swp"
        "**/.desktop.ini"
        "**/.direnv/"
        "**/.DS_Store"
        "**/.idea/"
        "**/__pycache__/"
        "**/build/"
        "**/dist/"
        "**/node_modules/"
        "**/result/"
      ];
      settings = {
        alias = {
          "graph" = "log --abbrev-commit --all --color --decorate --graph --oneline";
        };
        color.ui = true;
        help.autocorrect = 1;
        init.defaultBranch = "main";
        log.date = "human";
        pull.ff = "only";
        push.autoSetupRemote = true;
        url = {
          "git@github.com:".insteadOf = "github:";
          "https://github.com/".insteadOf = "github/";
        };
        user = {
          email = "26680023+CosasDePuma@users.noreply.github.com";
          name = "Kike Fontán";
        };
      };
    };

    # --- lsd
    lsd = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      settings.color.when = "always";
    };

    # --- mcps
    mcp = {
      enable = true;
      servers = {
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

    # --- starship
    starship = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      presets = [ "nerd-font-symbols" ];
      settings = {
        character = {
          error_symbol = "[[💩](red) ❯](peach)";
          success_symbol = "[[🦄](green) ❯](peach)";
        };
        directory = {
          format = "[$path]($style)[$read_only]($read_only_style) ";
          read_only = " 🔒";
          style = "bold lavender";
          truncate_to_repo = true;
          truncation_length = 4;
        };
        git_branch.style = "bold mauve";
        nix_shell = {
          format = "[$symbol$name]($style) ";
          style = "bold blue";
        };
        sudo.disabled = true;
      };
    };

    # --- vscode
    vscode = {
      enable = true;
      profiles =
        let
          vsconfig =
            extras:
            lib.mkMerge [
              {
                enableMcpIntegration = true;
                extensions = with pkgs.vscode-extensions; [
                  #anthropic.claude-code # TODO(after-update): current version is broken, needs update
                  github.copilot-chat
                  gruntfuggly.todo-tree
                  jnoortheen.nix-ide
                  mkhl.direnv
                  seatonjiang.gitmoji-vscode
                  tamasfe.even-better-toml
                ];
                userSettings = {
                  "editor.fontFamily" = "'FiraCode Nerd Font Mono', monospace";
                  "terminal.integrated.fontFamily" = "'FiraCode Nerd Font Mono'";
                  "explorer.fileNesting.enabled" = true;
                  "explorer.fileNesting.patterns" = {
                    "flake.nix" = "flake.lock";
                    "pyproject.toml" = "poetry.lock,uv.lock";
                  };
                  "terminal.integrated.fontLigatures.enabled" = true;
                  "todo-tree.tree.hideTreeWhenEmpty" = true;
                };
              }
              extras
            ];
        in
        {
          "default" = vsconfig { };
          "python" = vsconfig {
            extensions = with pkgs.vscode-extensions; [
              ms-python.python
            ];
          };
        };
    };

    # --- zoxide
    zoxide = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      options = [ "--cmd cd" ];
    };

    # --- zsh
    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion = {
        enable = true;
        strategy = [ "history" ];
      };
      history = {
        share = true;
        size = 10000;
      };
      shellAliases = {
        ".." = "\\cd ..";
        "cat" = "${pkgs.bat}/bin/bat";
      };
      shellGlobalAliases = {
        "-h" = "-h 2>&1 | ${pkgs.bat}/bin/bat --language=help";
        "--help" = "--help 2>&1 | ${pkgs.bat}/bin/bat --language=help";
      };
    };
  };

  # ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  # ┃                 Services                  ┃
  # ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

  services = {
    # --- ssh-agent
    ssh-agent = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
    };
  };

  # ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  # ┃                   Theme                   ┃
  # ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

  catppuccin = {
    enable = true;
    cursors.enable = false;
    flavor = "macchiato";
    vscode.profiles = {
      "default" = { };
      "python" = { };
    };
  };
}
