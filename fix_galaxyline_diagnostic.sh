#!/bin/bash

sed -ri 's/lsp.diagnostic.get_count\([^)]*\)[^)]*\)/#(vim.diagnostic.get(0))/' ~/.local/share/nvim/site/pack/packer/start/galaxyline.nvim/lua/galaxyline/provider_diagnostic.lua

echo "'vim.lsp.diagnostic.get_count() is deprecated' error won't appear now."
