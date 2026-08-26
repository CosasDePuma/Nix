{
  colors,
  colorsFile,
  backgroundsDir,
  ghosttyTheme ? null,
  vscodeExtension ? null,
  vscodeTheme ? null,
  gtkTheme ? null,
  cursorTheme ? null,
  extraFiles ? {},
}: {
  config ? {},
  lib,
  pkgs,
  ...
}: let
  themeName = builtins.baseNameOf (builtins.dirOf (builtins.toString backgroundsDir));
  themeShareDir = ".local/share/themes/${themeName}";

  imageExts = [".webp" ".png" ".jpg" ".jpeg"];
  allFiles = builtins.attrNames (builtins.readDir backgroundsDir);
  images = builtins.filter (f: builtins.any (ext: lib.hasSuffix ext f) imageExts) allFiles;
  sortedImages = builtins.sort builtins.lessThan images;
  defaultWallpaper = backgroundsDir + "/${builtins.head sortedImages}";

  theme-switcher = import ./theme-switcher.nix {inherit pkgs;};

  wallpaperFiles = builtins.listToAttrs (map (f: {
      name = "${themeShareDir}/wallpapers/${f}";
      value = {source = backgroundsDir + "/${f}";};
    })
    images);

  ghosttyThemeName =
    if ghosttyTheme != null
    then ghosttyTheme
    else if builtins.pathExists (builtins.dirOf (builtins.toString backgroundsDir) + "/ghostty-theme")
    then lib.strings.trim (builtins.readFile (builtins.dirOf (builtins.toString backgroundsDir) + "/ghostty-theme"))
    else "";

  resolvedVscodeExtension =
    if builtins.isFunction vscodeExtension
    then vscodeExtension pkgs
    else vscodeExtension;

  resolvedGtkTheme =
    if builtins.isFunction gtkTheme
    then gtkTheme pkgs
    else gtkTheme;

  resolvedCursorTheme =
    if builtins.isFunction cursorTheme
    then cursorTheme pkgs
    else cursorTheme;

  cleanHex = c: lib.strings.removePrefix "#" c;

  ghosttyConf =
    (
      if ghosttyThemeName != ""
      then "theme = ${ghosttyThemeName}\n"
      else ""
    )
    + ''
      background = #${cleanHex colors.background}
      foreground = #${cleanHex colors.foreground}
      cursor-color = #${cleanHex (colors.bright_foreground or colors.foreground)}
      selection-background = #${cleanHex (colors.selection or colors.muted)}
      selection-foreground = #${cleanHex (colors.bright_foreground or colors.foreground)}

      palette = 0=#${cleanHex colors.background}
      palette = 1=#${cleanHex (colors.red or colors.accent)}
      palette = 2=#${cleanHex (colors.green or colors.accent)}
      palette = 3=#${cleanHex (colors.yellow or colors.accent)}
      palette = 4=#${cleanHex (colors.blue or colors.accent)}
      palette = 5=#${cleanHex (colors.magenta or colors.accent)}
      palette = 6=#${cleanHex (colors.cyan or colors.accent)}
      palette = 7=#${cleanHex colors.foreground}
      palette = 8=#${cleanHex (colors.muted or colors.foreground)}
      palette = 9=#${cleanHex (colors.bright_red or colors.red or colors.accent)}
      palette = 10=#${cleanHex (colors.bright_green or colors.green or colors.accent)}
      palette = 11=#${cleanHex (colors.bright_yellow or colors.yellow or colors.accent)}
      palette = 12=#${cleanHex (colors.bright_blue or colors.blue or colors.accent)}
      palette = 13=#${cleanHex (colors.bright_magenta or colors.magenta or colors.accent)}
      palette = 14=#${cleanHex (colors.bright_cyan or colors.cyan or colors.accent)}
      palette = 15=#${cleanHex (colors.bright_foreground or colors.foreground)}
    '';

  hyprlandConf = ''
    general {
      col.active_border = rgba(${cleanHex colors.accent}ee) rgba(${cleanHex (colors.dark_foreground or colors.foreground)}ee) 45deg
      col.inactive_border = rgba(${cleanHex (colors.selection or colors.muted)}aa)
    }
  '';

  hyprlandLua = ''
    hl.config({
      general = {
        ["col.active_border"] = { colors = { "#${cleanHex colors.accent}ee", "#${cleanHex (colors.dark_foreground or colors.foreground)}ee" }, angle = 45 },
        ["col.inactive_border"] = "#${cleanHex (colors.selection or colors.muted)}aa",
      }
    })
  '';

  fuzzelIni = ''
    [colors]
    background=${cleanHex colors.background}f2
    text=${cleanHex colors.foreground}ff
    prompt=${cleanHex colors.accent}ff
    placeholder=${cleanHex colors.muted}ff
    input=${cleanHex colors.foreground}ff
    match=${cleanHex colors.accent}ff
    selection=${cleanHex colors.foreground}14
    selection-text=${cleanHex colors.accent}ff
    selection-match=${cleanHex (colors.bright_foreground or colors.foreground)}ff
    border=${cleanHex colors.foreground}ff
  '';

  makoConf = ''
    background-color=#${cleanHex colors.background}ff
    text-color=#${cleanHex colors.foreground}ff
    border-color=#${cleanHex colors.accent}ff
    border-size=2
    border-radius=10
    progress-color=over #${cleanHex colors.accent}ff
  '';

  herdrToml = ''
    onboarding = false

    # Mirrors the Omarchy tmux config in config/tmux/tmux.conf
    # tmux session -> herdr workspace, tmux window -> herdr tab, tmux pane -> herdr pane

    [theme]
    # tmux ran on the terminal's own palette (bg=default, fg=default, ANSI blue accents)
    name = "terminal"

    [theme.custom]
    # The active tab is drawn as panel_bg text on an accent background, so panel_bg
    # has to be dark for it to read - same colors as status-left's "#[fg=black,bg=blue]"
    panel_bg = "black"

    [terminal]
    new_cwd = "follow"

    [keys]
    prefix = "ctrl+space"

    # Config and help
    reload_config = "prefix+q"
    help = "prefix+?"
    detach = "prefix+d"

    # Copy mode
    copy_mode = "prefix+["

    # Panes
    split_horizontal = ["prefix+h", "alt+enter"]
    split_vertical = ["prefix+v", "alt+shift+enter"]
    close_pane = ["prefix+x", "alt+esc"]
    zoom = "prefix+z"
    last_pane = "prefix+;"

    focus_pane_left = "ctrl+alt+left"
    focus_pane_down = "ctrl+alt+down"
    focus_pane_up = "ctrl+alt+up"
    focus_pane_right = "ctrl+alt+right"

    resize_mode = ["prefix+ctrl+left", "prefix+ctrl+down", "prefix+ctrl+up", "prefix+ctrl+right"]

    # Like resize-pane on C-M-S-arrows
    resize_pane_left = "ctrl+alt+shift+left"
    resize_pane_down = "ctrl+alt+shift+down"
    resize_pane_up = "ctrl+alt+shift+up"
    resize_pane_right = "ctrl+alt+shift+right"

    # No tmux equivalent; herdr's default prefix+shift+p is taken by previous session
    rename_pane = "prefix+shift+o"

    # Windows -> tabs
    new_tab = "prefix+c"
    rename_tab = "prefix+r"
    close_tab = "prefix+k"
    switch_tab = ["prefix+1..9", "alt+1..9"]
    previous_tab = ["prefix+p", "alt+left"]
    next_tab = ["prefix+n", "alt+right"]

    # Like swap-window -t -1/+1 on M-S-Left/Right
    move_tab_previous = "alt+shift+left"
    move_tab_next = "alt+shift+right"

    # Sessions -> workspaces
    new_workspace = "prefix+shift+c"
    rename_workspace = "prefix+shift+r"
    close_workspace = "prefix+shift+k"
    previous_workspace = ["prefix+shift+p", "alt+up"]
    next_workspace = ["prefix+shift+n", "alt+down"]

    [ui]
    accent = "blue"
    pane_gaps = false
    pane_outer_borders = false
    pane_scrollbars = false
    confirm_close = false
    prompt_new_tab_name = false
    mouse_capture = true
    tab_bar_right = [{ type = "zoom" }, { type = "hostname" }]
    window_title = "{hostname}: {workspace}"
  '';

  shellToml = ''
    [bar]
    background       = "#${cleanHex colors.background}"
    background-alpha = 1.0
    text             = "#${cleanHex colors.foreground}"
    active           = "#${cleanHex (colors.red or colors.accent)}"
    scale-with-font  = true
    size-horizontal  = 26
    size-vertical    = 28

    [hyprland]
    active-border            = "#${colors.accent}"
    active-border-foreground = "#${colors.foreground}"

    [controls]
    normal-color        = "#${colors.foreground}"
    normal-fill-alpha   = 0.04
    normal-border       = "#${colors.foreground}"
    normal-border-width = 1
    normal-border-alpha = 0.4
    hover-cursor-color        = "#${colors.foreground}"
    hover-cursor-fill-alpha   = 0.08
    hover-cursor-border       = "#${colors.foreground}"
    hover-cursor-border-width = 1
    hover-cursor-border-alpha = 0.25
    focus-color        = "#${colors.foreground}"
    focus-fill-alpha   = 0.08
    focus-border       = "#${colors.foreground}"
    focus-border-width = 1
    focus-border-alpha = 0.25
    selected-color        = "#${colors.foreground}"
    selected-fill-alpha   = 0.18
    selected-border       = "#${colors.foreground}"
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
    background       = "#${colors.background}"
    background-alpha = 1.0
    text             = "#${colors.foreground}"
    border           = "hyprland.active-border"
    border-alpha     = 1.0

    [tooltip]
    background       = "#${colors.background}"
    background-alpha = 0.97
    text             = "#${colors.foreground}"
    border           = "hyprland.active-border-foreground"
    border-alpha     = 1.0

    [notifications]
    background       = "#${colors.background}"
    background-alpha = 1.0
    text             = "#${colors.foreground}"
    border           = "hyprland.active-border"
    border-alpha     = 1.0
    countdown        = "#${colors.accent}"

    [launcher]
    background                = "#${colors.background}"
    background-alpha          = 0.95
    text                      = "#${colors.foreground}"
    border                    = "hyprland.active-border-foreground"
    border-alpha              = 1.0
    scrim                     = "#${colors.background}"
    scrim-alpha               = 0.5
    selected-background       = "#${colors.foreground}"
    selected-background-alpha = 0.08
    selected-text             = "#${colors.accent}"
    selected-border           = "hyprland.active-border-foreground"
    selected-border-alpha     = 0.25

    [menu]
    background                = "#${colors.background}"
    background-alpha          = 1.0
    text                      = "#${colors.foreground}"
    border                    = "hyprland.active-border-foreground"
    border-alpha              = 1.0
    scrim                     = "#${colors.background}"
    scrim-alpha               = 0.5
    selected-background       = "#${colors.foreground}"
    selected-background-alpha = 0.08
    selected-text             = "#${colors.accent}"
    selected-border           = "hyprland.active-border-foreground"
    selected-border-alpha     = 0.25
  '';

  vscodeSettings =
    {
      "terminal.integrated.fontFamily" = "'FiraCode Nerd Font Mono', monospace";
      "explorer.fileNesting.enabled" = true;
      "explorer.fileNesting.patterns" = {
        "flake.nix" = "flake.lock";
        "pyproject.toml" = "poetry.lock,uv.lock";
      };
      "terminal.integrated.fontLigatures.enabled" = true;
      "todo-tree.tree.hideTreeWhenEmpty" = true;
    }
    // lib.optionalAttrs (vscodeTheme != null) {
      "workbench.colorTheme" = vscodeTheme;
    };

  vscodeJson = builtins.toJSON vscodeSettings;
in {
  home.packages = [theme-switcher];

  home.file =
    wallpaperFiles
    // {
      "${themeShareDir}/colors.toml".source = colorsFile;
      "${themeShareDir}/wallpaper".source = defaultWallpaper;
      "${themeShareDir}/ghostty.conf".text = ghosttyConf;
      "${themeShareDir}/hyprland.conf".text = hyprlandConf;
      "${themeShareDir}/hyprland.lua".text = hyprlandLua;
      "${themeShareDir}/fuzzel.ini".text = fuzzelIni;
      "${themeShareDir}/mako.conf".text = makoConf;
      "${themeShareDir}/herdr.toml".text = herdrToml;
      "${themeShareDir}/shell.toml".text = shellToml;
      "${themeShareDir}/vscode.json".text = vscodeJson;
    }
    // extraFiles;

  programs.vscode = lib.mkIf ((config.programs.vscode.enable or false) && resolvedVscodeExtension != null) {
    profiles = {
      default = {
        extensions = [resolvedVscodeExtension];
      };
      python = {
        extensions = [resolvedVscodeExtension];
      };
    };
  };

  gtk = lib.mkIf ((config.gtk.enable or false) && resolvedGtkTheme != null) {
    theme = {
      inherit (resolvedGtkTheme) package;
      inherit (resolvedGtkTheme) name;
    };
  };

  home.pointerCursor = lib.mkIf (resolvedCursorTheme != null) {
    enable = true;
    inherit (resolvedCursorTheme) package;
    inherit (resolvedCursorTheme) name;
    size = resolvedCursorTheme.size or 24;
    gtk.enable = true;
    hyprcursor.enable = true;
    x11.enable = true;
  };

  home.activation."initTheme_${themeName}" = lib.hm.dag.entryAfter ["writeBoundary"] ''
    state_theme="$HOME/.local/state/theme"
    default_theme="$HOME/.local/share/themes/${themeName}"
    if [ ! -e "$state_theme/name" ] && [ -d "$default_theme" ]; then
      mkdir -p "$state_theme"
      rm -f "$state_theme/current" 2>/dev/null || true
      ln -sfn "$default_theme/colors.toml" "$state_theme/colors.toml"
      ln -sfn "$default_theme/shell.toml" "$state_theme/shell.toml"
      ln -sfn "$default_theme/ghostty.conf" "$state_theme/ghostty.conf"
      ln -sfn "$default_theme/hyprland.conf" "$state_theme/hyprland.conf"
      ln -sfn "$default_theme/hyprland.lua" "$state_theme/hyprland.lua"
      ln -sfn "$default_theme/fuzzel.ini" "$state_theme/fuzzel.ini"
      ln -sfn "$default_theme/mako.conf" "$state_theme/mako.conf"
      ln -sfn "$default_theme/herdr.toml" "$state_theme/herdr.toml"
      ln -sfn "$default_theme/wallpaper" "$state_theme/wallpaper"
      ln -sfn "$default_theme/vscode.json" "$state_theme/vscode.json"
      printf '%s\n' "${themeName}" > "$state_theme/name"
    fi
  '';
}
