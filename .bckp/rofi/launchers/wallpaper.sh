#!/bin/sh

wallpapers=($(find ~/.local/share/wallpapers/ -mindepth 1 -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.svg" \) | sort))
options=""
for wallpaper in "${wallpapers[@]}"; do
    options="${options}$(basename "${wallpaper}")\0icon\x1f${wallpaper}\n"
done

selected=$(\echo -en "${options[@]}" | rofi -dmenu -show-icons -i -p "Select Wallpaper" -theme ~/.config/rofi/wallpapers.rasi)
if test -n "${selected}"; then
    path=""
    for wallpaper in "${wallpapers[@]}"; do
        if test "$(basename "${wallpaper}")" = "${selected}"; then
            path="${wallpaper}"
            break
        fi
    done
    swww img --transition-type 'grow' "${path}"
fi
