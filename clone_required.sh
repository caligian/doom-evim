#!/bin/bash

DEST="$HOME/.local/share/nvim/site/pack/packer/start"

git clone --depth 1 https://github.com/wbthomason/packer.nvim "$DEST/packer.nvim"
gt clone https://github.com/Olical/aniseed "$DEST/aniseed"
git clone https://github.com/Olical/conjure "$DEST/conjure"
git clone https://github.com/bakpakin/fennel.vim "$DEST/fennel.vim"

