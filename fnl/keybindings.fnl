(module keybindings
  {autoload {utils utils}})

; File management
(utils.define-keys [{:keys "<leader>fs"
                     :exec ":w<CR>"
                     :help "Save curent file"}

                    {:keys "<leader>fv"
                     :exec ":w <bar> source %<CR>"
                     :help "Source current file"}

                    {:keys "<leader>fp"
                     :exec ":e ~/.config/nvim/fnl<CR>"
                     :help "Open doom config dir"}

                    {:keys "<leader>fP"
                     :exec ":e ~/.vdoom.d<CR>"
                     :help "Open private config dir"}

                    {:keys "<leader>fV"
                     :exec ":source ~/.config/nvim/init.lua<CR>"
                     :help "Source doom's init.lua"}

                    ; Tab management 
                    {:keys "<leader>tk"
                     :exec ":tabclose<CR>"
                     :help "Close current tab"}

                    {:keys "<leader>tn"
                     :exec ":tabnext<CR>"
                     :help "Go to next tab"}

                    {:keys "<leader>tp"
                     :exec ":tabprevious<CR>"
                     :help "Go to previous tab"}

                    {:keys "<leader>tf"
                     :exec ":tabfind"
                     :help "Find tab"}

                    {:keys "<leader>te"
                     :exec ":tabedit<CR>"
                     :help "Open file in a new tab"}

                    {:keys "<leader>tt"
                     :exec ":tabnew<CR>"
                     :help "Open a new tab"}

                    ; Buffers 
                    {:keys "<leader>qw"
                     :exec ":xa!<CR>"
                     :help "Save buffers and quit"}

                    {:keys "<leader>bp"
                     :exec ":bprev<CR>"
                     :help "Previous buffer"}

                    {:keys "<leader>bn"
                     :exec ":bnext<CR>"
                     :help "Next buffer"}

                    {:keys "<leader>br"
                     :exec ":e<CR>"
                     :help "Revert buffer"}

                    {:keys "<leader>bk"
                     :exec ":hide<CR>"
                     :help "Hide current buffer"}

                    {:keys "<leader>qq"
                     :exec ":qa!<CR>"
                     :help "Quit unconditionally"}

                    {:keys "<del>"
                     :exec ":noh<CR>"
                     :help "No highlight"}

                    ; Easy command access
                    {:keys ";"
                     :exec ": "
                     :help "Open command mode"}
                    
                    {:keys "!"
                     :exec ":! "
                     :help "Execute an sh command"}
                    
                    ; Clipboad
                    {:keys "<leader>xp"
                     :help "Paste from clipboard"
                     :exec ":normal! \"+p<CR>"}])


; Reload entire config
(utils.define-keys [{:keys "<leader>hrr"
                     :help "Reload doom"
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
(utils.define-keys [{:keys "<PageDown>"
                     :exec (utils.respect-count utils.decrease-indent false true)
                     :help "Decrease indent"}

                    {:keys "<PageUp>"
                     :exec (utils.respect-count utils.increase-indent false true)
                     :help "Increase indent"}

                    {:keys "<S-PageDown>"
                     :modes ["v"]
                     :exec #(utils.line-range-exec utils.decrease-indent)
                     :help "Decrease indent in range"}

                    {:keys "<S-PageUp>"
                     :modes ["v"]
                     :exec #(utils.line-range-exec utils.increase-indent) 
                     :help "Increase indent in range"}])

