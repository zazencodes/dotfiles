#!/bin/bash

DOTFILES_DIR=~/dotfiles/bin
TARGET_DIR=~/bin

for file in "$DOTFILES_DIR"/*; do
    filename=$(basename "$file")
    target="$TARGET_DIR/$filename"

    if [ -L "$target" ]; then
        echo "$target already exists as a symlink."
    elif [ -e "$target" ]; then
        echo "$target already exists as a regular file."
    else
        ln -s "$file" "$target"
        echo "Created symlink: $target -> $file"
    fi
done
