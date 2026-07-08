#!/bin/sh

themes=($(find ~/.config/colorschemes -mindepth 1 -maxdepth 1 -type d ! -iname '.*' -exec basename {} \; | sort))
selected=$(\printf '%s\n' "${themes[@]}" | rofi -dmenu -i -p "Select Theme")

if test -n "${selected}"; then
    /bin/sh ~/.config/colorschemes/colorscheme.sh "${selected}"
fi
