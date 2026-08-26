{pkgs}:
pkgs.writeShellApplication {
  name = "theme-switcher";
  runtimeInputs = [
    pkgs.coreutils
    pkgs.findutils
    pkgs.hyprland
    pkgs.libnotify
    pkgs.mako
    pkgs.procps
    pkgs.quickshell
    pkgs.swaybg
    pkgs.vips
  ];
  text = ''
    themes_dir="$HOME/.local/share/themes"
    cache_dir="''${XDG_CACHE_HOME:-$HOME/.cache}/omarchy/theme-selector"
    preview_dir="$cache_dir/previews"

    if [ ! -d "$themes_dir" ]; then
      "${pkgs.libnotify}/bin/notify-send" "Theme" "No themes installed"
      exit 0
    fi

    themes=()
    while IFS= read -r d; do
      [ -d "$d" ] && themes+=("$("${pkgs.coreutils}/bin/basename" "$d")")
    done < <("${pkgs.findutils}/bin/find" "$themes_dir" -mindepth 1 -maxdepth 1 -type d | "${pkgs.coreutils}/bin/sort")

    if [ ''${#themes[@]} -eq 0 ]; then
      "${pkgs.libnotify}/bin/notify-send" "Theme" "No themes installed"
      exit 0
    fi

    "${pkgs.coreutils}/bin/mkdir" -p "$preview_dir"
    "${pkgs.coreutils}/bin/rm" -rf "$preview_dir"
    "${pkgs.coreutils}/bin/mkdir" -p "$preview_dir"

    rows_file=$("${pkgs.coreutils}/bin/mktemp")
    trap '"${pkgs.coreutils}/bin/rm" -f "$rows_file"' EXIT

    for theme in "''${themes[@]}"; do
      theme_path="$themes_dir/$theme"
      wallpapers_dir="$theme_path/wallpapers"
      image=$("${pkgs.findutils}/bin/find" -L "$wallpapers_dir" -maxdepth 1 -type f \( -iname "*.webp" -o -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" \) | "${pkgs.coreutils}/bin/sort" | "${pkgs.coreutils}/bin/head" -n1)

      [ -n "$image" ] || continue

      thumbnail="$cache_dir/$theme.thumb.jpg"
      if [ ! -f "$thumbnail" ]; then
        "${pkgs.vips}/bin/vipsthumbnail" "$image" --size 1536x864 --smartcrop=centre --path "$thumbnail" 2>/dev/null || thumbnail="$image"
      fi

      "${pkgs.coreutils}/bin/printf" '%s\t%s\t%s\n' "$image" "$thumbnail" "$theme" >> "$rows_file"
    done

    if [ ! -s "$rows_file" ]; then
      "${pkgs.libnotify}/bin/notify-send" "Theme" "No theme previews found"
      exit 0
    fi

    current_theme=""
    if [ -f "$HOME/.local/state/theme/name" ]; then
      current_theme=$("${pkgs.coreutils}/bin/cat" "$HOME/.local/state/theme/name")
    fi

    rows_b64=$("${pkgs.coreutils}/bin/base64" -w 0 < "$rows_file")
    selection_file=$("${pkgs.coreutils}/bin/mktemp")
    done_file=$("${pkgs.coreutils}/bin/mktemp")
    "${pkgs.coreutils}/bin/rm" -f "$done_file"
    trap '"${pkgs.coreutils}/bin/rm" -f "$rows_file" "$selection_file" "$done_file"' EXIT

    image_selector="${builtins.toString ./image-selector}"

    export THEME_SELECTOR_ROWS_B64="$rows_b64"
    export THEME_SELECTOR_SELECTION_FILE="$selection_file"
    export THEME_SELECTOR_DONE_FILE="$done_file"
    export THEME_SELECTOR_SELECTED="$current_theme"

    "${pkgs.quickshell}/bin/quickshell" -n -p "$image_selector" &
    selector_pid=$!

    while [ ! -e "$done_file" ]; do
      if ! "${pkgs.procps}/bin/kill" -0 "$selector_pid" 2>/dev/null; then
        exit 0
      fi
      "${pkgs.coreutils}/bin/sleep" 0.01
    done

    "${pkgs.procps}/bin/kill" "$selector_pid" 2>/dev/null || true
    "${pkgs.procps}/bin/wait" "$selector_pid" 2>/dev/null || true

    if [ -s "$selection_file" ]; then
      theme_name=$("${pkgs.coreutils}/bin/cat" "$selection_file")
      target_theme="$themes_dir/$theme_name"

      if [ -d "$target_theme" ]; then
        state_theme="$HOME/.local/state/theme"
        "${pkgs.coreutils}/bin/mkdir" -p "$state_theme"
        "${pkgs.coreutils}/bin/rm" -f "$state_theme/current" 2>/dev/null || true
        "${pkgs.coreutils}/bin/ln" -sfn "$target_theme/colors.toml" "$state_theme/colors.toml"
        "${pkgs.coreutils}/bin/ln" -sfn "$target_theme/shell.toml" "$state_theme/shell.toml"
        "${pkgs.coreutils}/bin/ln" -sfn "$target_theme/ghostty.conf" "$state_theme/ghostty.conf"
        "${pkgs.coreutils}/bin/ln" -sfn "$target_theme/hyprland.conf" "$state_theme/hyprland.conf"
        "${pkgs.coreutils}/bin/ln" -sfn "$target_theme/hyprland.lua" "$state_theme/hyprland.lua"
        "${pkgs.coreutils}/bin/ln" -sfn "$target_theme/fuzzel.ini" "$state_theme/fuzzel.ini"
        "${pkgs.coreutils}/bin/ln" -sfn "$target_theme/mako.conf" "$state_theme/mako.conf"
        "${pkgs.coreutils}/bin/ln" -sfn "$target_theme/herdr.toml" "$state_theme/herdr.toml"
        "${pkgs.coreutils}/bin/ln" -sfn "$target_theme/wallpaper" "$state_theme/wallpaper"
        "${pkgs.coreutils}/bin/printf" '%s\n' "$theme_name" > "$state_theme/name"

        "${pkgs.hyprland}/bin/hyprctl" reload >/dev/null 2>&1 || true
        "${pkgs.mako}/bin/makoctl" reload >/dev/null 2>&1 || true
        "${pkgs.procps}/bin/pkill" -USR2 -f ghostty 2>/dev/null || true

        wallpaper_file="$state_theme/wallpaper"
        if [ -f "$wallpaper_file" ]; then
          "${pkgs.procps}/bin/pkill" -i -f swaybg 2>/dev/null || true
          "${pkgs.swaybg}/bin/swaybg" -i "$wallpaper_file" -m fill >/dev/null 2>&1 &
        fi

        "${pkgs.libnotify}/bin/notify-send" "Theme" "Switched to $theme_name"
      fi
    fi
  '';
}
