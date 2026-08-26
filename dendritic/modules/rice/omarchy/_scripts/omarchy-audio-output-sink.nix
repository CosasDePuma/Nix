{pkgs}:
pkgs.writeShellApplication {
  name = "omarchy-audio-output-sink";
  runtimeInputs = [pkgs.pulseaudio pkgs.gawk];
  text = ''
    sink="''${1:-$(pactl get-default-sink 2>/dev/null)}"

    if [[ -z $sink || $sink == alsa_output.* ]]; then
      printf '%s\n' "$sink"
      exit 0
    fi

    downstream="$(pactl list sink-inputs 2>/dev/null |
      awk -v virt="$sink" '
        /^Sink Input #/ {target = ""}
        /^[[:space:]]*Sink:/ {target = $2}
        /node\.name = / {
          name = $0
          sub(/.*node\.name = "/, "", name)
          sub(/"$/, "", name)
          if (index(name, virt) == 1 && target != "") {print target; exit}
        }
        /application\.name = "EasyEffects"/ {
          if (virt == "easyeffects_sink" && target != "") {print target; exit}
        }')"

    if [[ -n $downstream ]]; then
      name="$(pactl list sinks short 2>/dev/null |
        awk -v id="$downstream" '$1 == id {print $2; exit}')"
      if [[ -n $name ]]; then
        printf '%s\n' "$name"
        exit 0
      fi
    fi

    printf '%s\n' "$sink"
  '';
}
