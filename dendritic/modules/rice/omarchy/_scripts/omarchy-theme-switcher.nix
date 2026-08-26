{pkgs}:
pkgs.writeShellApplication {
  name = "omarchy-theme-switcher";
  runtimeInputs = [pkgs.coreutils pkgs.fuzzel pkgs.libnotify pkgs.procps pkgs.swaybg];
  text = ''
    theme_dir="$HOME/.config/omarchy/themes"
    if [ ! -d "$theme_dir" ]; then
      notify-send "Omarchy" "No themes installed yet"
      exit 0
    fi
    theme=$(find "$theme_dir" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort | fuzzel --dmenu --prompt "🎨 ") || exit 0
    wallpaper=$(find "$theme_dir/$theme" -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' \) | head -n 1)
    if [ -n "$wallpaper" ]; then
      pkill -x swaybg 2>/dev/null || true
      nohup swaybg -i "$wallpaper" -m fill >/dev/null 2>&1 &
    fi
    printf '%s\n' "$theme" > "$HOME/.config/omarchy/current-theme"
    notify-send "Omarchy" "Theme: $theme"
  '';
}
