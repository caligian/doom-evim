(module specs
  {autoload {utils utils}})

(local specs! _G.specs!)

; MarkdownPreview does not build itself by default. 
(specs! :markdown-preview.nvim {:lock true 
                                :run "cd app && yarn install"})

(specs! :telescope-fzf-native.nvim {:run "make"})
