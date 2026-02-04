#!/bin/bash
# Usage:
#   ./symlink_dotfiles.sh bin
#   ./symlink_dotfiles.sh opt

if [ -z "$1" ]; then
  echo "Usage: $(basename "$0") <folder>"
  exit 1
fi

FOLDER="$1"

DOTFILES_DIR=~/dotfiles/$FOLDER
TARGET_DIR=~/$FOLDER

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

