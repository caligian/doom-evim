(module keybindings
  {autoload {utils utils
             vimp vimp}})

; File management
(utils.define-keys [{:keys "<C-ScrollWheelUp>"
                     :exec #(utils.adjust-font-size "+")
                     :help "Increase font size"}

                    {:keys "<C-ScrollWheelDown>"
                     :exec #(utils.adjust-font-size "-")
                     :help "Decrease font size"}
                    
                    {:keys "<leader>fs"
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

                    {:keys "<leader>bR"
                     :exec ":set readonly<CR>"
                     :help "Read-only buffer"}

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
                    {:keys "<leader>;"
                     :exec ": "
                     :help "Open command mode"}
                    
                    {:keys "<localleader>&"
                     :exec #(utils.async-sh (utils.get-user-input "bash % " 
                                                                  (fn [input]
                                                                    (let [input (utils.match-sed input
                                                                                           ["{%}" "{%:p}" "{%:t}" "{%:e}" "{%:h}" "{%:r}"] 
                                                                                           [(vim.fn.expand "%")
                                                                                            (vim.fn.expand "%:p")
                                                                                            (vim.fn.expand "%:t")
                                                                                            (vim.fn.expand "%:e")
                                                                                            (vim.fn.expand "%:h")
                                                                                            (vim.fn.expand "%:r")])]
                                                                      input))
                                                                  true
                                                                  {:use_function true}))
                     :help "Run an async sh command"}
                  
                    ; Clipboad
                    {:keys "<leader>xp"
                     :help "Paste from clipboard"
                     :exec ":normal! \"+p<CR>"}])

; Reload entire config
(utils.define-keys [{:keys "<leader>hrl"
                     :help "Toggle colorscheme background"
                     :exec #(let [current vim.o.background]
                              (match current
                                :dark (set vim.o.background :light)
                                :light (set vim.o.background :dark))
                              (vim.cmd  (utils.fmt ":source %s" (utils.confp :lua :modeline.lua))))}

                    {:keys "<leader>hrf"
                     :help "Switch between Gohu and BitstreamVeraSans"
                     :exec #(let [font (string.gsub vim.o.guifont ":h[0-9]+$" "")
                                  font-size (utils.grep vim.o.guifont "[0-9]+$")
                                  new-font (if (utils.grep font "GohuFont")
                                             (.. "UbuntuMono NF:h" 14)
                                             (.. "GohuFont NF:h11"))]
                              (set vim.o.guifont new-font))}

                    {:keys "<leader>hrt"
                     :help "Reload doom theme"
                     :exec (fn []
                             (vim.cmd  (utils.fmt ":source %s" (utils.confp :lua :modeline.lua))))}

                    {:keys "<leader>hrr"
                     :help "Reload doom"
                     :exec (fn [] 
                             (require :init)
                             (require :modeline)
                             (set doom.user_packages (require :user-packages))
                             (set doom.default_packages (require :default_packages)))}])

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

; Quickfix List operations
(utils.define-keys [{:keys "<leader>q/" 
                     :help "Run vimgrep on current dir"
                     :exec (fn []
                             (let [input (utils.get-user-input "Search for: > "
                                                               #(~= $1 "")
                                                               true)
                                   cmd (utils.fmt ":vimgrep /%s/ *" input)]
                               (vim.cmd cmd)))}

                    {:keys "<leader>qf"
                     :noremap false
                     :help "Toggle qflist"
                     :exec "<Plug>(qf_qf_toggle)"}

                    {:keys "<localleader>q/" 
                     :help "Run vimgrep on current buffer"
                     :exec (fn []
                             (let [current-file (vim.fn.expand "%:p")
                                   input (utils.get-user-input "Search for: > "
                                                               #(~= $1 "")
                                                               true)
                                   cmd (utils.fmt ":vimgrep /%s/ %s" input current-file)]
                               (vim.cmd cmd)))}

                    {:keys "<localleader>qr"
                     :help "Search requires in buffer"
                     :key-attribs "buffer"
                     :patterns "fennel"
                     :events "FileType"
                     :exec ":vimgrep /(require/ *fnl %<CR>"}

                    {:keys "<localleader>qf"
                     :help "Search defns in buffer"
                     :key-attribs "buffer"
                     :patterns "fennel"
                     :events "FileType"
                     :exec ":vimgrep /(defn / *fnl %<CR>"}

                    {:keys "<localleader>qL"
                     :help "Search locals in buffer"
                     :key-attribs "buffer"
                     :patterns "fennel"
                     :events "FileType"
                     :exec ":vimgrep /(local / *fnl %<CR>"}

                    {:keys "<localleader>qm"
                     :help "Jump to module"
                     :key-attribs "buffer"
                     :patterns "fennel"
                     :events "FileType"
                     :exec ":vimgrep /(module/ *<CR>"}

                    {:keys "<localleader>qR"
                     :help "Search requires"
                     :key-attribs "buffer"
                     :patterns "fennel"
                     :events "FileType"
                     :exec ":vimgrep /(require/ *fnl<CR>"}

                    {:keys "<localleader>qF"
                     :help "Search defns"
                     :key-attribs "buffer"
                     :patterns "fennel"
                     :events "FileType"
                     :exec ":vimgrep /(defn / *fnl<CR>"}

                    {:keys "<localleader>qL"
                     :help "Search locals"
                     :key-attribs "buffer"
                     :patterns "fennel"
                     :events "FileType"
                     :exec ":vimgrep /(local / *fnl<CR>"}])

; Copy default_packages.lua to ~/.vdoom.d/ as user-packages.lua
; Useful for testing
(vimp.map_command "CopyDefaultPackages" #(utils.sh "cp ~/.config/nvim/lua/default_packages.lua ~/.vdoom.d/user-packages.lua"))
(vimp.map_command "CopyUserPackages" #(utils.sh "cp ~/.vdoom.d/user-packages.lua ~/.config/nvim/lua/default_packages.lua"))
(vimp.map_command "EditDefaultPackages" #(utils.exec ":e ~/.config/nvim/lua/default_packages.lua"))
(vimp.map_command "EditUserPackages" #(utils.exec ":e ~/.vdoom.d/user-packages.lua"))
(vimp.map_command "CopySamplePackages" #(utils.sh "cp ~/.config/nvim/lua/default_packages.lua ~/.config/nvim/sample-user-configs/user-packages.lua"))
