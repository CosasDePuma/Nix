{
  inputs,
  lib,
  ...
}: let
  warpSettings = ''
    [appearance.input]
    input_mode = "waterfall"

    [appearance.text]
    font_name = "FiraCode Nerd Font Mono"
    font_size = 15.0
    ligature_rendering_enabled = true

    [terminal.input]
    honor_ps1 = true
    input_box_type_setting = "classic"

    [privacy]
    telemetry_enabled = false
    crash_reporting_enabled = false

    [warp_drive]
    enabled = false

    [agents.warp_agent.other]
    show_conversation_history = false

    [agents.third_party]
    cli_agent_toolbar_chip_selection_setting = { custom = { left = ["file_attach"], right = [{ context_chip = "working_directory" }, { context_chip = "git_branch_status" }] } }
  '';

  claudeCodeWarp = {
    owner = "warpdotdev";
    repo = "claude-code-warp";
    rev = "e0e18e162aa5ec97a6d4cecdf66b08b75eb1e149";
    hash = "sha256-ZMSQBLd9kCZfVqZX6VvMn6KnyM8a5zuTu+5ctltG5GQ=";
  };
in {
  flake = {
    darwinModules.software-warp = {
      homebrew.casks = ["warp"];
    };

    homeManagerModules.software-warp = {
      pkgs,
      config,
      # Shadows the outer file-level `lib` with home-manager's own extended
      # one, which is what actually has `.hm` (needed for `lib.hm.dag.*`).
      lib,
      ...
    }: let
      settingsPath =
        if pkgs.stdenv.hostPlatform.isDarwin
        then ".warp/settings.toml"
        else ".config/warp-terminal/settings.toml";
    in {
      imports = [inputs.self.homeManagerModules.fonts-firacode];
      config = lib.mkMerge [
        {
          # No mkDefault: home.file.<path>.text is types.lines, which
          # concatenates same-priority definitions instead of picking a
          # winner. That's what lets a theme module append its own
          # [appearance.themes] block here without replacing this one --
          # mkDefault would drop this whole definition the moment anything
          # else set the same path at normal priority.
          home.file.${settingsPath}.text = warpSettings;
        }
        (lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
          # Warp stages downloaded updates under this dir before offering to
          # install them; making it immutable stops that write, which is
          # also what suppresses the "a new version is available" nag (it
          # never gets a staged update to point at). uchg is settable by a
          # normal user on their own files, unlike Linux's chattr +i.
          home.activation.disableWarpAutoupdate = lib.hm.dag.entryAfter ["writeBoundary"] ''
            autoupdateDir="$HOME/Library/Application Support/dev.warp.Warp-Stable/autoupdate"
            mkdir -p "$autoupdateDir"
            /usr/bin/chflags -R uchg "$autoupdateDir" 2>/dev/null || true
          '';
        })
        (lib.mkIf (config.programs.opencode.enable or false) {
          programs.opencode.settings.plugin = ["@warp-dot-dev/opencode-warp"];
        })
        (lib.mkIf (config.programs.claude-code.enable or false) {
          programs.claude-code.plugins."warp" = "${pkgs.fetchFromGitHub claudeCodeWarp}/plugins/warp";
        })
      ];
    };

    nixosModules.software-warp = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [warp-terminal];

      # Unlike on Darwin, Warp on Linux never stages an update locally --
      # it only polls for a new version and shows the "new version" nag
      # straight off that response (confirmed via its own log: "Starting
      # autoupdate polling loop" / "Checking for update on channel stable").
      # There's no local write step to lock down, so block the check itself.
      #
      # releases.warp.dev alone isn't enough: it only serves the actual
      # update *download*. The version-check response that drives the nag
      # ("Received channel versions from Warp server") comes back over
      # app.warp.dev, the main API server -- confirmed live, the nag kept
      # firing with releases.warp.dev blocked. Blocking app.warp.dev too
      # kills whatever else routes through it (auth/sync/AI features,
      # anything not on the separate rtc./sessions. subdomains) -- accepted
      # tradeoff to actually stop the nag, not an accident.
      #
      # networking.hosts entries are multi-owner/additive (any module may
      # want to blackhole a different host under the same IP), so no
      # mkDefault here. Needs both families per host: AAAA records exist
      # too, and NSS falls through to real DNS per-family when /etc/hosts
      # only covers one of them.
      networking.hosts = {
        "127.0.0.1" = ["releases.warp.dev" "app.warp.dev"];
        "::1" = ["releases.warp.dev" "app.warp.dev"];
      };
    };
  };
}
