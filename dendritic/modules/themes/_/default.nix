{
  colors,
  colorsFile,
  backgroundsDir,
  ghosttyTheme ? null,
  extraFiles ? {},
}: {
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

  ghosttyConf =
    if ghosttyThemeName != ""
    then "theme = ${ghosttyThemeName}\n"
    else "";

  hyprlandConf = ''
    general {
      col.active_border = rgba(${colors.accent}ee) rgba(${colors.dark_foreground or colors.foreground}ee) 45deg
      col.inactive_border = rgba(${colors.selection or colors.muted}aa)
    }
  '';

  hyprlandLua = ''
    hl.config({
      general = {
        ["col.active_border"] = { colors = { "#${colors.accent}ee", "#${colors.dark_foreground or colors.foreground}ee" }, angle = 45 },
        ["col.inactive_border"] = "#${colors.selection or colors.muted}aa",
      }
    })
  '';

  fuzzelIni = ''
    [colors]
    background=${colors.background}f2
    text=${colors.foreground}ff
    prompt=${colors.accent}ff
    placeholder=${colors.muted}ff
    input=${colors.foreground}ff
    match=${colors.accent}ff
    selection=${colors.foreground}14
    selection-text=${colors.accent}ff
    selection-match=${colors.bright_foreground or colors.foreground}ff
    border=${colors.foreground}ff
  '';

  makoConf = ''
    background-color=#${colors.background}ff
    text-color=#${colors.foreground}ff
    border-color=#${colors.accent}ff
    border-size=2
    border-radius=10
    progress-color=over #${colors.accent}ff
  '';

  herdrToml = ''
    [theme.custom]
    sidebar_bg = "#${colors.background}"
    active_row_bg = "#${colors.lighter_background or colors.background}"
    selection_bg = "#${colors.selection or colors.muted}"
    accent = "#${colors.accent}"
    green = "#${colors.green or colors.accent}"
    blue = "#${colors.blue or colors.accent}"
    red = "#${colors.red or colors.accent}"
    yellow = "#${colors.yellow or colors.accent}"
  '';

  shellToml = ''
    [bar]
    background       = "#${colors.background}"
    background-alpha = 1.0
    text             = "#${colors.foreground}"
    active           = "#${colors.red or colors.accent}"
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
    }
    // extraFiles;

  home.activation.initTheme = lib.hm.dag.entryAfter ["writeBoundary"] ''
    state_theme="$HOME/.local/state/theme"
    default_theme="$HOME/.local/share/themes/${themeName}"
    if [ ! -e "$state_theme/current" ] && [ -d "$default_theme" ]; then
      mkdir -p "$state_theme"
      ln -sfn "$default_theme" "$state_theme/current"
      ln -sfn "$default_theme/colors.toml" "$state_theme/colors.toml"
      ln -sfn "$default_theme/shell.toml" "$state_theme/shell.toml"
      ln -sfn "$default_theme/ghostty.conf" "$state_theme/ghostty.conf"
      ln -sfn "$default_theme/hyprland.conf" "$state_theme/hyprland.conf"
      ln -sfn "$default_theme/hyprland.lua" "$state_theme/hyprland.lua"
      ln -sfn "$default_theme/fuzzel.ini" "$state_theme/fuzzel.ini"
      ln -sfn "$default_theme/mako.conf" "$state_theme/mako.conf"
      ln -sfn "$default_theme/herdr.toml" "$state_theme/herdr.toml"
      ln -sfn "$default_theme/wallpaper" "$state_theme/wallpaper"
      printf '%s\n' "${themeName}" > "$state_theme/name"
    fi
  '';
}
