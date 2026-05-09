{inputs, ...}: {
  flake.modules.nixos.firefox-software = _: {
    home-manager.users.rabbit = {pkgs, ...}: let
      extension = name: "https://addons.mozilla.org/firefox/downloads/latest/${name}/latest.xpi";
      firefox-addons = inputs.firefox-addons.packages.${pkgs.stdenv.hostPlatform.system};
    in {
      programs.firefox = {
        enable = true;
        configPath = ".mozilla/firefox";
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
            "support@lastpass.com" = {
              default_area = "menupanel";
              install_url = extension "lastpass-password-manager";
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
            Allow = ["https://addons.mozilla.org"];
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
              packages = with firefox-addons; [
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
    };
  };
}
