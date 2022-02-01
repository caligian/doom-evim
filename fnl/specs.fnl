(module specs
  {autoload {utils utils}})

(local specs! _G.specs!)

; MarkdownPreview does not build itself by default. 
(specs! :markdown-preview.nvim {:lock true 
                                :run "cd app && yarn install"})

; Fix the bug where `lsp.diagnostic.get_count()` annoys the fuck out of the user
(specs! :galaxyline.nvim {:lock true
                          :run "cp ~/.config/nvim/support/provider_diagnostic.lua ~/.local/share/nvim/site/pack/packer/start/galaxyline.nvim/lua/galaxyline/provider_diagnostic.lua"})
