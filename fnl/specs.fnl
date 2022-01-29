(module specs)

(local specs! _G.specs!)

; MarkdownPreview does not build itself by default. 
(specs! :markdown-preview.nvim {:lock true 
                                :run "cd app && yarn install"})

; Fix the bug where `lsp.diagnostic.get_count()` annoys the fuck out of the user
(specs! :galaxyline.nvim {:lock true
                          :run "bash ~/.config/nvim/fix_galaxyline_diagnostic.sh"})

