(module vim-vsnip-config
  {autoload {utils utils}})

(utils.define-keys [{:keys "<C-j>"
                     :noremap false
                     :modes "s"
                     :exec "vsnip#expandable()  ? '<Plug>(vsnip-expand)'         : '<C-j>'"
                     :key-attribs "expr"
                     :help "Expand snippet"}

                    {:keys "<C-j>"
                     :noremap false
                     :modes "i"
                     :exec "vsnip#expandable()  ? '<Plug>(vsnip-expand)'         : '<C-j>'"
                     :key-attribs "expr"
                     :help "Expand snippet"}

                    {:keys "<C-l>"
                     :modes "s"
                     :key-attribs "expr"
                     :noremap false
                     :help "Expand or jump snippet"
                     :exec "vsnip#available(1)  ? '<Plug>(vsnip-expand-or-jump)' : '<C-l>'"}

                    {:keys "<C-l>"
                     :modes "i"
                     :noremap false
                     :key-attribs "expr"
                     :help "Expand or jump snippet"
                     :exec "vsnip#available(1)  ? '<Plug>(vsnip-expand-or-jump)' : '<C-l>'"}

                    {:keys "<S-Tab>"
                     :noremap false
                     :key-attribs "expr"
                     :modes "i"
                     :help "Snippet jump to next field"
                     :exec "vsnip#jumpable(1)   ? '<Plug>(vsnip-jump-prev)'      : '<Tab>'"}

                    {:keys "<S-Tab>"
                     :key-attribs "expr"
                     :noremap false
                     :modes "i"
                     :help "Snippet jump to prev field"
                     :exec "vsnip#jumpable(1)   ? '<Plug>(vsnip-jump-prev)'      : '<Tab>'"}

                    {:keys "<Tab>"
                     :noremap false
                     :key-attribs "expr"
                     :modes "s"
                     :help "Snippet jump to next field"
                     :exec "vsnip#jumpable(1)   ? '<Plug>(vsnip-jump-next)'      : '<Tab>'"}

                    {:keys "<Tab>"
                     :key-attribs "expr"
                     :noremap false
                     :modes "i"
                     :help "Snippet jump to next field"
                     :exec "vsnip#jumpable(1)   ? '<Plug>(vsnip-jump-next)'      : '<Tab>'"}])
