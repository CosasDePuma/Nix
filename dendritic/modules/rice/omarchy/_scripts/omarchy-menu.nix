{pkgs}:
pkgs.writeShellApplication {
  name = "omarchy-menu";
  runtimeInputs = [pkgs.jq];
  text = ''
    verb="''${1:-toggle}"
    route="''${2:-root}"

    menu_payload() {
      jq -nc --arg menu "$1" '{ menu: $menu }'
    }

    case "$verb" in
      toggle)
        exec omarchy-shell shell toggle omarchy.menu "$(menu_payload "$route")"
        ;;
      summon)
        exec omarchy-shell shell summon omarchy.menu "$(menu_payload "$route")"
        ;;
      close)
        exec omarchy-shell shell hide omarchy.menu
        ;;
      refresh | ping)
        exec omarchy-shell shell call omarchy.menu "$verb" "{}"
        ;;
      *)
        echo "Usage: omarchy-menu [toggle|summon|close|refresh|ping] [route]" >&2
        exit 1
        ;;
    esac
  '';
}
