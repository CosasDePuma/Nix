_: let
  vendor = ./omarchy-shell/vendor;
in {
  flake.homeManagerModules.software-omarchy-shell = {
    lib,
    pkgs,
    ...
  }: let
    # Pure IPC client, port of upstream bin/omarchy-shell: forwards
    # <target> <method> [args...] to the running instance through qs ipc.
    # It never starts quickshell itself -- launching is omarchy-launch-shell's
    # job -- so callers get "not running" errors instead of a second bar.
    omarchy-shell = pkgs.writeShellApplication {
      name = "omarchy-shell";
      runtimeInputs = [pkgs.coreutils pkgs.quickshell];
      text = ''
        QUIET=0
        if [[ ''${1:-} == "-q" ]]; then
          QUIET=1
          shift
        fi

        fail() {
          (( QUIET )) && exit 0
          echo "$1" >&2
          exit 1
        }

        if (( $# == 0 )) || [[ $1 == "-h" || $1 == "--help" ]]; then
          cat <<USAGE
        Usage: omarchy-shell [-q] <target> <method> [args...]

        Forwards an IPC call to the running Omarchy shell. The shell is expected
        to already be running; this command does not start it.

        Options:
          -q  Quiet best-effort mode. Suppress output and return success even when
              the shell, target, method, or arguments are unavailable.
        USAGE
          exit 0
        fi

        (( $# >= 2 )) || fail "Usage: omarchy-shell <target> <method> [args...]"
        # Default to the vendored app instead of requiring the variable:
        # callers outside the session don't inherit home.sessionVariables,
        # and an unset path would break every lookup below.
        export OMARCHY_PATH="''${OMARCHY_PATH:-${vendor}}"
        [[ -f $OMARCHY_PATH/shell/shell.qml ]] || fail "omarchy-shell config not found: $OMARCHY_PATH/shell/shell.qml"

        # qs matches instances by display, and a caller from outside the
        # session (ssh or TTY) has none, so recover it from the compositor
        # socket.
        if [[ -z ''${WAYLAND_DISPLAY:-} ]]; then
          socket=$(ls -t "''${XDG_RUNTIME_DIR:-/run/user/$UID}"/wayland-[0-9]* 2>/dev/null | grep -v '\.lock$' | head -n1)
          [[ -n $socket ]] && export WAYLAND_DISPLAY=''${socket##*/}
        fi

        if [[ $1 == "shell" && ( $2 == "summon" || $2 == "toggle" ) ]] && (( $# == 3 )); then
          set -- "$1" "$2" "$3" "{}"
        fi

        # The -- keeps function names that shadow qs subcommands (e.g. show) as
        # positionals. qs reports connection failures with a nonzero exit, but
        # IPC-level failures (unknown target/function, bad arguments) go to
        # stdout with exit 0.
        ipc_timeout=''${OMARCHY_SHELL_IPC_TIMEOUT:-2s}
        output=$(timeout --kill-after=1s "$ipc_timeout" qs ipc -n -p "$OMARCHY_PATH/shell" call -- "$@" 2>/dev/null)
        ipc_status=$?

        if (( ipc_status == 124 || ipc_status == 137 )); then
          fail "omarchy-shell is not responding"
        elif (( ipc_status != 0 )); then
          fail "omarchy-shell is not running"
        fi

        case $output in
          "Target not found." | "Function not found." | "Too few arguments provided"* | "Too many arguments provided"*)
            fail "$output"
            ;;
          # A starting shell answers on stdout and exits 0, so a ping reads it
          # as up and the next call's answer as a result. It is as unreachable
          # as none.
          "Not ready to accept queries yet"*)
            fail "omarchy-shell is not ready"
            ;;
        esac

        if (( !QUIET )) && [[ -n $output ]]; then
          echo "$output"
        fi
        exit 0
      '';
    };

    # Supervisor, port of upstream bin/omarchy-launch-shell: starts the shell
    # under systemd-cat (journal keeps the event trail across sessions),
    # restarts it on crashes with a rate-limited budget, and stops trying
    # when the compositor itself is going away.
    omarchy-launch-shell = pkgs.writeShellApplication {
      name = "omarchy-launch-shell";
      runtimeInputs = [pkgs.coreutils pkgs.hyprland pkgs.quickshell pkgs.systemd pkgs.util-linux];
      text = ''
        export OMARCHY_PATH="''${OMARCHY_PATH:-${vendor}}"

        # Quickshell's own reloading is off; Omarchy restarts the shell
        # deliberately. A store path is immutable anyway, so there is nothing
        # to hot-reload against.
        run_shell() {
          QS_DISABLE_FILE_WATCHER=1 QS_NO_RELOAD_POPUP=1 \
            systemd-cat -t omarchy-shell -- quickshell -n -p "$OMARCHY_PATH/shell" &
          shell_pid=$!

          local status
          while true; do
            wait "$shell_pid"
            status=$?

            # An interrupted wait and a shell killed by that signal report alike.
            kill -0 "$shell_pid" 2>/dev/null || break
          done

          shell_pid=""
          return $status
        }

        # A compositor busy reconfiguring outputs can miss a query without
        # being gone, and that is when the shell dies.
        compositor_alive() {
          local attempt

          for attempt in 1 2 3; do
            hyprctl -j monitors >/dev/null 2>&1 && return 0
            (( attempt < 3 )) && sleep 0.5
          done

          return 1
        }

        terminating=0
        shell_pid=""

        stop() {
          terminating=1
          [[ -n $shell_pid ]] && kill -TERM "$shell_pid" 2>/dev/null
          return 0
        }
        trap stop HUP INT TERM

        attempts=0
        window_started=$SECONDS

        while true; do
          # A signal during the backoff only reaches the trap once the sleep
          # is over.
          (( terminating )) && exit 0

          run_shell
          status=$?

          (( terminating )) && exit 0
          (( status == 0 )) && exit 0

          # Relaunching into a session already tearing down burns the attempt
          # budget.
          compositor_alive || exit 0

          if (( SECONDS - window_started > 60 )); then
            attempts=0
            window_started=$SECONDS
          fi

          if (( ++attempts > 5 )); then
            logger -t omarchy-shell "Giving up on the Omarchy shell after $attempts relaunches in under a minute."
            exit 1
          fi

          logger -t omarchy-shell "Omarchy shell exited with status $status; relaunching."
          sleep 1
        done
      '';
    };
  in {
    # The single source of truth for where the vendored shell app + its
    # bundled defaults live. Points at the Nix store, not ~/.config/omarchy
    # (that's per-user state -- shell.json overrides, themes -- a distinct
    # concept upstream keeps separate too).
    home.sessionVariables.OMARCHY_PATH = lib.mkDefault "${vendor}";

    home.packages = [
      omarchy-launch-shell
      omarchy-shell
    ];

    systemd.user.services.omarchy-shell = {
      Unit = {
        Description = "Omarchy Quickshell bar";
        PartOf = ["graphical-session.target"];
        After = ["graphical-session.target"];
      };
      Service = {
        # systemd --user services don't inherit home.sessionVariables (those
        # land in ~/.zshenv, read only by login shells), so OMARCHY_PATH has
        # to be set here too -- both for this script's own "$OMARCHY_PATH"
        # and because shell.qml itself reads it via Quickshell.env() in the
        # spawned process.
        Environment = ["OMARCHY_PATH=${vendor}"];
        # No Restart here: the launcher supervises crashes itself with a
        # bounded retry budget and hands control back on clean stops.
        ExecStart = "${omarchy-launch-shell}/bin/omarchy-launch-shell";
      };
      Install.WantedBy = ["graphical-session.target"];
    };
  };
}
