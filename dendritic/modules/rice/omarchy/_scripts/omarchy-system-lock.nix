{pkgs}:
pkgs.writeShellApplication {
  name = "omarchy-system-lock";
  text = ''
    omarchy-shell lock lock >/dev/null
    hyprctl switchxkblayout all 0 >/dev/null 2>&1 || true
  '';
}
