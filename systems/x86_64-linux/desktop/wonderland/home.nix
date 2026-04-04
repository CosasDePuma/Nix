{
  lib ? throw "not imported as module",
  pkgs ? throw "not imported as module",
  stateVersion ? "25.05",
  firefox-addons,
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

    # --- firefox
    firefox =
      let
        extension = name: "https://addons.mozilla.org/firefox/downloads/latest/${name}/latest.xpi";
      in
      {
        enable = true;
        package = pkgs.firefox-esr;
        policies = {
          AutofillAddressEnabled = false;
          AutofillCreditCardEnabled = false;
          Bookmarks = [
            {
              Placement = "toolbar";
              Title = "Profiles";
              URL = "about:profiles";
            }
          ];
          BrowserDataBackup = {
            AllowBackup = false;
            AllowRestore = false;
          };
          CaptivePortal = false;
          Cookies.Behavior = "reject-tracker-and-partition-foreign";
          DisableFeedbackCommands = true;
          DisableFirefoxAccounts = true;
          DisableFirefoxStudies = true;
          DisableForgetButton = true;
          DisableFormHistory = true;
          DisablePocket = true;
          DisableProfileImport = true;
          DisableProfileRefresh = true;
          DisableSetDesktopBackground = true;
          DisableTelemetry = true;
          DontCheckDefaultBrowser = true;
          EnableTrackingProtection = {
            Category = "strict";
            Cryptomining = true;
            EmailTracking = true;
            Fingerprinting = true;
            SuspectedFingerprinting = true;
            Value = true;
          };
          ExtensionSettings = {
            "{a5726845-3a00-4076-8601-b9b943dfcddc}" = {
              install_url = extension "catppuccin-macchiato-rosewater";
              installation_mode = "force_installed";
            };
            "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
              default_area = "navbar";
              install_url = extension "bitwarden-password-manager";
              installation_mode = "normal_installed";
              private_browsing = true;
            };
          };
          FirefoxHome = {
            Highlights = false;
            Locked = true;
            Pocket = false;
            Search = true;
            SponsoredPocket = false;
            SponsoredStories = false;
            SponsoredTopSites = false;
            Stories = false;
            TopSites = false;
          };
          FirefoxSuggest = {
            ImproveSuggest = false;
            SponsoredSuggestions = false;
            WebSuggestions = false;
          };
          GenerativeAI = {
            Enabled = false;
            Locked = true;
          };
          InstallAddonsPermission = {
            Default = false;
            Allow = [ "https://addons.mozilla.org" ];
          };
          OfferToSaveLogins = false;
          OverrideFirstRunPage = "";
          OverridePostUpdatePage = "";
          PasswordManagerEnabled = false;
          Preferences = {
            "browser.startup.homepage" = "about:newtab";
            "browser.startup.page" = 1;
            "privacy.trackingprotection.socialtracking.enabled" = true;
          };
          SanitizeOnShutdown = {
            Cache = true;
            Downloads = true;
            FormData = true;
          };
          SearchEngines = {
            Add = [
              {
                Name = "NixOS";
                Alias = "@nix";
                IconURL = "https://search.nixos.org/favicon.png";
                URLTemplate = "https://search.nixos.org/packages?channel=unstable&query={searchTerms}";
              }
              {
                Name = "YouTube";
                Alias = "@yt";
                IconURL = "https://www.youtube.com/favicon.ico";
                URLTemplate = "https://www.youtube.com/results?search_query={searchTerms}";
              }
            ];
            Default = "Google";
            PreventInstalls = true;
            Remove = [
              "Bing"
              "DuckDuckGo"
              "Ecosia"
              "Perplexity"
              "Qwant"
              "Wikipedia (en)"
            ];
          };
          SkipTermsOfUse = true;
          TranslateEnabled = true;
          UserMessaging = {
            ExtensionRecommendations = false;
            FeatureRecommendations = false;
            FirefoxLabs = false;
            MoreFromMozilla = false;
            SkipOnboarding = true;
          };
        };
        profiles = {
          "personal" = {
            isDefault = true;
            name = "Personal";
            extensions.force = true;
          };
          "bugbounty" = {
            name = "Bug bounty";
            bookmarks = {
              force = true;
              settings = [
                {
                  name = "Toolbar";
                  toolbar = true;
                  bookmarks = [
                    {
                      name = "BugBounty";
                      bookmarks = [
                        {
                          name = "Bugcrowd";
                          url = "https://bugcrowd.com/engagements?category=bug_bounty&sort_by=starts&sort_direction=desc&page=1";
                        }
                        {
                          name = "HackerOne";
                          url = "https://hackerone.com/directory/programs?offers_bounties=true&order_direction=DESC&order_field=launched_at";
                        }
                        {
                          name = "Intigriti";
                          url = "https://www.intigriti.com/researchers/bug-bounty-programs?programs_prod%5Bmenu%5D%5BprogramType%5D=Bug%20bounty%20program";
                        }
                        {
                          name = "YesWeHack";
                          url = "https://yeswehack.com/programs";
                        }
                      ];
                    }
                    {
                      name = "BugBounty DeFi";
                      bookmarks = [
                        {
                          name = "Code4rena";
                          url = "https://code4rena.com/audits";
                        }
                        {
                          name = "Sherlock";
                          url = "https://audits.sherlock.xyz/contests?filter=active";
                        }
                      ];
                    }
                  ];
                }
              ];
            };
            extensions = {
              force = true;
              packages = with firefox-addons.${pkgs.stdenv.hostPlatform.system}; [
                metamask
              ];
            };
            settings = {
              "browser.urlbar.suggest.bookmark" = false;
              "browser.urlbar.suggest.history" = false;
              "browser.urlbar.suggest.openpage" = false;
              "browser.urlbar.suggest.quickactions" = false;
            };
            id = 1;
          };
        };
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
                  "terminal.integrated.fontFamily" = "'FiraCode Nerd Font Mono', monospace";
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
    flavor = "macchiato";
    vscode.profiles = {
      "default" = { };
      "python" = { };
    };
  };
}
