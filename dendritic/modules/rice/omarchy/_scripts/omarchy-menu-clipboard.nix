{pkgs}:
pkgs.writeShellApplication {
  name = "omarchy-menu-clipboard";
  text = ''
    exec omarchy-shell shell toggle omarchy.clipboard
  '';
}
