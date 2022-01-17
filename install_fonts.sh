#!/bin/bash

FONTS="$HOME/.config/nvim/misc/FiraCode/"
DEST="$HOME/.local/share/fonts"

cp $FONTS/* $DEST/

echo "FiraCode has been installed."

# Reload fonts
fc-cache -r &>/dev/null

echo "Please restart neovim if it is open in order to use the new fonts"
