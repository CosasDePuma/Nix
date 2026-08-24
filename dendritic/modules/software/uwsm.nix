{lib, ...}: {
  flake.nixosModules.software-uwsm = {
    programs.uwsm.enable = lib.mkDefault true;

    # Compositors ship two session entries: their own direct launcher and the
    # uwsm-managed one. Prune everything but the uwsm-managed entries so
    # greeters only offer sessions through the uwsm envelope.
    environment.extraSetup = ''
      for file in "$out"/share/wayland-sessions/*.desktop; do
        case ''${file##*/} in
          *-uwsm.desktop) ;;
          *) rm -f "$file" ;;
        esac
      done
    '';
  };
}
