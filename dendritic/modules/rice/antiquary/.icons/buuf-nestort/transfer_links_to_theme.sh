#!/bin/bash

if [ "$#" -ne 3 ]; then
    echo -e "\nThis script attempts to transfers all the symbolic links in buuf-nestort's theme to any other theme\n"
    echo -e "Usage: $(basename "$0") <source theme base directory> <destination theme base directory> <destination file extension>"
    echo -e "eg: $(basename "$0") . ~/Themes/icons/elementary-xfce svg\n"
    exit 1
fi

extension=$3

THEME_A=$(readlink -f "$1")
THEME_DEST=$(readlink -f "$2")

# Ensure both directories exist
if [ ! -d "$THEME_A" ] || [ ! -d "$THEME_DEST" ]; then
    echo "Error: One or both directories do not exist."
    exit 1
fi

declare -a FOLDERS=(actions applets apps categories devices emblems emotes mimetypes places status)


for folder in "${FOLDERS[@]}"; do
    THEME_A_FOLDER="$THEME_A/$folder"
    THEME_DEST_FOLDER="$THEME_DEST/$folder"
    
    # Ensure the folder exists both in source and destination
    if [ ! -d "$THEME_A_FOLDER" ] || [ ! -d "$THEME_DEST_FOLDER" ]; then
        echo "skipping '$folder' folder because it does not exist both in source ($THEME_A_FOLDER) and destination ($THEME_DEST_FOLDER) themes..."
        continue
    fi

    find "$THEME_A_FOLDER" -type l | while read -r symlink; do
        link_name=$(basename "$symlink")
        target=$(readlink "$symlink")
        target_name=$(basename "$target")
        target_folder=$(dirname "$target")

        #remove the links' extensions
        link_no_ext="${link_name%.*}"
        target_no_ext="${target_name%.*}"
        echo -e "   found a link: $link_no_ext -> $target_folder/$target_no_ext"

        for res_folder in $(ls "$THEME_DEST_FOLDER"); do
            echo -e "      entering '$THEME_DEST_FOLDER/$res_folder' to see if the destination exists for the link, and there is no file already with this name"
            link_source="$THEME_DEST_FOLDER/$res_folder/$link_no_ext.$extension"
            link_dest="$THEME_DEST_FOLDER/$target_folder/$res_folder/$target_no_ext.$extension"
            if [ ! -f "$link_source" ] && [ -f "$link_dest" ]; then
                echo "      Destination exists and source doesn't, so I'll create the link: $link_source -> $link_dest"
                ln -sr "$link_dest" "$link_source"
            fi
        done

    done
done

