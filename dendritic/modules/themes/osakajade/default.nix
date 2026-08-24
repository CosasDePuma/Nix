_: let
  colors = builtins.fromTOML (builtins.readFile ./colors.toml);
  wallpaper = ./backgrounds/1-glowing-city.webp;
in {
  flake.homeManagerModules.themes-osakajade = {
    config,
    lib,
    pkgs,
    ...
  }: let
    # fuzzel.ini wants bare RRGGBBAA, no leading #.
    hex = c: lib.removePrefix "#" c;
    warpSettingsPath =
      if pkgs.stdenv.hostPlatform.isDarwin
      then ".warp/settings.toml"
      else ".config/warp-terminal/settings.toml";
    warpThemesDir =
      if pkgs.stdenv.hostPlatform.isDarwin
      then ".warp/themes"
      else ".local/share/warp-terminal/themes";
    warpTheme = ''
      accent: "${colors.accent}"
      background: "${colors.background}"
      details: darker
      foreground: "${colors.foreground}"
      terminal_colors:
        normal:
          black: "${colors.darker_background}"
          red: "${colors.red}"
          green: "${colors.green}"
          yellow: "${colors.yellow}"
          blue: "${colors.blue}"
          magenta: "${colors.magenta}"
          cyan: "${colors.cyan}"
          white: "${colors.light_foreground}"
        bright:
          black: "${colors.muted}"
          red: "${colors.bright_red}"
          green: "${colors.bright_green}"
          yellow: "${colors.bright_yellow}"
          blue: "${colors.bright_blue}"
          magenta: "${colors.bright_magenta}"
          cyan: "${colors.bright_cyan}"
          white: "${colors.bright_foreground}"
    '';
  in
    # --- hyprland
    lib.mkIf (config.wayland.windowManager.hyprland.enable or false) {
      wayland.windowManager.hyprland.settings.config.general = {
        "col.active_border" = lib.mkDefault (
          lib.generators.mkLuaInline ''{colors = {"${colors.accent}ee", "${colors.dark_foreground}ee"}, angle = 45}''
        );
        "col.inactive_border" = lib.mkDefault "${colors.selection}aa";
      };

      # --- mako
      # Mirrors omarchy's own shell.toml [notifications] tokens (background,
      # foreground, accent border/countdown) so a notify-send toast looks
      # like it belongs, even though upstream now renders these itself
      # through Quickshell instead of mako.
      services.mako.settings = {
        background-color = "${colors.background}ff";
        text-color = colors.foreground;
        border-color = colors.accent;
        border-size = 2;
        border-radius = 10;
        progress-color = "over ${colors.accent}";
      };

      # --- fuzzel (SUPER + SPACE launcher, also used by the clipboard and
      # theme-switcher menus). Mirrors omarchy's shell.toml [launcher]
      # tokens: background/text/border follow the same background,
      # foreground, and hyprland-active-border-foreground (-> foreground,
      # no override set) roles upstream uses for its own launcher overlay.
      programs.fuzzel.settings = {
        colors = {
          background = "${hex colors.background}f2"; # alpha 0.95, like upstream
          text = hex colors.foreground;
          prompt = hex colors.accent;
          placeholder = hex colors.muted;
          input = hex colors.foreground;
          match = hex colors.accent;
          selection = "${hex colors.foreground}14"; # alpha 0.08, like upstream
          selection-text = hex colors.accent;
          selection-match = hex colors.bright_foreground;
          border = hex colors.foreground;
        };
        border = {
          width = 2;
          radius = 10;
        };
      };

      # --- omarchy-shell (the bar). Renders the bar-relevant sections of
      # upstream's default/themed/shell.toml.tpl by hand, substituting our
      # palette for its {{ token }} placeholders; "hyprland.active-border"
      # style values are left as literal strings, which is how the shell
      # itself resolves them (Commons/Color.qml recurses into
      # [hyprland].active-border rather than expecting a hex value there).
      # Sections not on the bar's surface (polkit, lock, image-picker) are
      # left out.
      home.file.".local/state/omarchy/current/theme/colors.toml".source = ./colors.toml;
      home.file.".local/state/omarchy/current/theme/shell.toml".text = ''
        [bar]
        background       = "${colors.background}"
        background-alpha = 1.0
        text             = "${colors.foreground}"
        active           = "${colors.red}"
        scale-with-font  = true
        size-horizontal  = 26
        size-vertical    = 28

        [hyprland]
        active-border            = "${colors.accent}"
        active-border-foreground = "${colors.foreground}"

        [controls]
        normal-color        = "${colors.foreground}"
        normal-fill-alpha   = 0.04
        normal-border       = "${colors.foreground}"
        normal-border-width = 1
        normal-border-alpha = 0.4
        hover-cursor-color        = "${colors.foreground}"
        hover-cursor-fill-alpha   = 0.08
        hover-cursor-border       = "${colors.foreground}"
        hover-cursor-border-width = 1
        hover-cursor-border-alpha = 0.25
        focus-color        = "${colors.foreground}"
        focus-fill-alpha   = 0.08
        focus-border       = "${colors.foreground}"
        focus-border-width = 1
        focus-border-alpha = 0.25
        selected-color        = "${colors.foreground}"
        selected-fill-alpha   = 0.18
        selected-border       = "${colors.foreground}"
        selected-border-width = 0
        selected-border-alpha = 1.0
        pressed-fill-alpha   = 0.22
        selection-fill-alpha = 0.35

        [spacing]
        scale = 1.0
        scale-with-font = true

        [font]
        base-size = 12

        [popups]
        background       = "${colors.background}"
        background-alpha = 1.0
        text             = "${colors.foreground}"
        border           = "hyprland.active-border"
        border-alpha     = 1.0

        [tooltip]
        background       = "${colors.background}"
        background-alpha = 0.97
        text             = "${colors.foreground}"
        border           = "hyprland.active-border-foreground"
        border-alpha     = 1.0

        [notifications]
        background       = "${colors.background}"
        background-alpha = 1.0
        text             = "${colors.foreground}"
        border           = "hyprland.active-border"
        border-alpha     = 1.0
        countdown        = "${colors.accent}"

        [launcher]
        background                = "${colors.background}"
        background-alpha          = 0.95
        text                      = "${colors.foreground}"
        border                    = "hyprland.active-border-foreground"
        border-alpha              = 1.0
        scrim                     = "${colors.background}"
        scrim-alpha               = 0.5
        selected-background       = "${colors.foreground}"
        selected-background-alpha = 0.08
        selected-text             = "${colors.accent}"
        selected-border           = "hyprland.active-border-foreground"
        selected-border-alpha     = 0.25

        [menu]
        background                = "${colors.background}"
        background-alpha          = 1.0
        text                      = "${colors.foreground}"
        border                    = "hyprland.active-border-foreground"
        border-alpha              = 1.0
        scrim                     = "${colors.background}"
        scrim-alpha               = 0.5
        selected-background       = "${colors.foreground}"
        selected-background-alpha = 0.08
        selected-text             = "${colors.accent}"
        selected-border           = "hyprland.active-border-foreground"
        selected-border-alpha     = 0.25
      '';

      # --- warp
      # software-warp.nix's own home.file.${settingsPath}.text has no
      # mkDefault (see the comment there): this is a second, same-priority
      # definition of that same path, so home-manager's types.lines merge
      # concatenates it onto the base settings instead of one replacing
      # the other.
      home.file."${warpThemesDir}/osaka-jade.yaml".text = warpTheme;
      home.file.${warpSettingsPath}.text = ''

        [appearance.themes]
        theme = { custom = { name = "Osaka Jade", path = "~/${warpThemesDir}/osaka-jade.yaml" } }
      '';

      # --- wallpaper
      systemd.user.services.wallpaper = {
        Unit = {
          Description = "Wallpaper";
          PartOf = ["graphical-session.target"];
          After = ["graphical-session.target"];
          StartLimitIntervalSec = 60;
          StartLimitBurst = 10;
        };
        Service = {
          ExecStart = "${pkgs.swaybg}/bin/swaybg -i ${wallpaper} -m fill";
          Restart = "on-failure";
          RestartSec = "2s";
        };
        Install.WantedBy = ["graphical-session.target"];
      };
    };
}
