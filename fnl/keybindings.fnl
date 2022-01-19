(module keybindings
  {autoload {utils utils}})

; File management
(vim.cmd "noremap <leader>fs :w<CR>")
(vim.cmd "noremap <leader>fv :w <bar> source %<CR>")
(vim.cmd "noremap <leader>fp :e! ~/.config/nvim/lua<CR>")
(vim.cmd "noremap <leader>fV :source ~/.config/nvim/init.vim<CR>")

; Font size 
; Tab management 
(vim.cmd "noremap <leader>tk :tabclose<CR>")
(vim.cmd "noremap <leader>tn :tabnext<CR>")
(vim.cmd "noremap <leader>tp :tabprevious<CR>")
(vim.cmd "noremap <leader>tf :tabfind<CR>")
(vim.cmd "noremap <leader>te :tabedit<CR>")
(vim.cmd "noremap <leader>tt :tabnew<CR>")

; Buffers 
(vim.cmd "noremap <leader>qw :xa!<CR>")
(vim.cmd "noremap <leader>bp :bprev<CR>")
(vim.cmd "noremap <leader>bn :bnext<CR>")
(vim.cmd "noremap <leader>br :e<CR>")
(vim.cmd "noremap <leader>bk :hide<CR>")
(vim.cmd "noremap <leader>qq :qa!<CR>")
(vim.cmd "noremap <del> :noh<CR>")
(vim.cmd "noremap <leader><leader> : ")

; Open terminal quickly
(vim.cmd "noremap <F1> :tabnew <bar> term bash<CR>")

; Clipboard stuff
(vim.cmd "noremap <leader>xp :normal! \"+p<CR>") 
(vim.cmd "vnoremap <leader>xy :'<'>normal! \"+y<CR>")

; Reload entire config
(utils.define-keys [{:keys "<leader>hrr"
                     :exec (fn [] 
                             (vim.cmd "tabnew") 
                             (vim.cmd "edit ~/.config/nvim/fnl/init.fnl")
                             (vim.cmd "ConjureEvalBuf")

                             (if (> (vim.call "tabpagenr") 1)
                               (vim.cmd "tabclose")
                               (vim.cmd (.. ":Bdelete " "init.fnl")))

                             (vim.cmd "echom \"Successfully reloaded Doom!\""))}])
; Quickly adjust indentation
; Respects v:count and lines in visual range
(utils.define-keys [{:keys "<A-h>"
                     :exec (utils.respect-count utils.decrease-indent true true)
                     :help "Decrease indent"}

                    {:keys "<A-l>"
                     :exec (utils.respect-count utils.increase-indent true true)
                     :help "Increase indent"}

                    {:keys "<A-h>"
                     :modes ["v"]
                     :exec (utils.register #(utils.line-range-exec utils.decrease-indent) true)
                     :help "Decrease indent in range"}

                    {:keys "<A-l>"
                     :modes ["v"]
                     :exec (utils.register #(utils.line-range-exec utils.increase-indent) true)
                     :help "Increase indent in range"}])
