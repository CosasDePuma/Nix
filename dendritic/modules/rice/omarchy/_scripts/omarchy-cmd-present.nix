{pkgs}:
pkgs.writeShellApplication {
  name = "omarchy-cmd-present";
  text = ''
    for cmd in "$@"; do
      command -v "$cmd" >/dev/null 2>&1 || exit 1
    done
    exit 0
  '';
}
