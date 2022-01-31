#!/bin/bash

cp support/provider_diagnostic.lua ~/.local/share/nvim/site/pack/packer/start/galaxyline.nvim/lua/galaxyline/provider_diagnostic.lua

echo "'vim.lsp.diagnostic.get_count() is deprecated' error won't appear now."
