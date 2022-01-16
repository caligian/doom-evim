(module keybindings
  {autoload {utils utils}})

; Non-package keybindings

; Debugging-related keybindings
; Python
(utils.define-keys [{:noremap true 
                     :keys "<leader>dts"
                     :events "BufEnter"
                     :key-attribs ["buffer"]
                     :patterns "*py"
                     :exec (utils.split-termdebug-buffer "python3.9" "-m pdb" "sp" true true)}

                    {:noremap true 
                     :keys "<leader>dtv"
                     :key-attribs ["buffer"]
                     :events "BufEnter"
                     :patterns "*py"
                     :exec (utils.split-termdebug-buffer "python3.9" "-m pdb" "vsp" true true)}])

; Ruby
(utils.define-keys [{:noremap true 
                     :keys "<leader>dts"
                     :events "BufEnter"
                     :key-attribs ["buffer"]
                     :patterns "*rb"
                     :exec (utils.split-termdebug-buffer "ruby" "-r debug" "sp" true true)}

                    {:noremap true 
                     :keys "<leader>dtv"
                     :key-attribs ["buffer"]
                     :events "BufEnter"
                     :patterns "*rb"
                     :exec (utils.split-termdebug-buffer "ruby" "-r debug" "vsp" true true)}])

; In order to use lua debugger, use this command 
; sudo cp ~/.config/nvim/lua/debugger.lua /usr/local/share/lua/5.1/
; Then `require "debugger"` in your script
; Lua
(utils.define-keys [{:noremap true 
                     :keys "<leader>dts"
                     :events "BufEnter"
                     :key-attribs ["buffer"]
                     :patterns "*lua"
                     :exec (utils.split-termdebug-buffer "lua" "" "sp" true true)}

                    {:noremap true 
                     :keys "<leader>dtv"
                     :key-attribs ["buffer"]
                     :events "BufEnter"
                     :patterns "*lua"
                     :exec (utils.split-termdebug-buffer "lua" "" "vsp" true true)}])

; bash
(utils.define-keys [{:noremap true 
                     :keys "<leader>dts"
                     :events "BufEnter"
                     :key-attribs ["buffer"]
                     :patterns "*sh"
                     :exec (utils.split-termdebug-buffer "bash" "-x" "sp" true true)}

                    {:noremap true 
                     :keys "<leader>dtv"
                     :key-attribs ["buffer"]
                     :events "BufEnter"
                     :patterns "*sh"
                     :exec (utils.split-termdebug-buffer "bash" "-x" "vsp" true true)}])

; File management
(vim.cmd "noremap <leader>fs :w<CR>")
(vim.cmd "noremap <leader>fv :w <bar> source %<CR>")
(vim.cmd "noremap <leader>fp :e! ~/.config/nvim/lua<CR>")
(vim.cmd "noremap <leader>fV :source ~/.config/nvim/init.vim<CR>")
; vim.cmd "noremap <F7> :lua doom.utils.compilebuf"

; Font size 
; vim.cmd "<C-ScrollWheelUp> :lua doom.utils.setfontsize(1)<CR>"
; vim.cmd "<C-ScrollWheelDown> :lua doom.utils.setfontsize(-1)<CR>"

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
(vim.cmd "noremap <leader>bk :hide<CR>")
(vim.cmd "noremap <leader>qq :qa!<CR>")
(vim.cmd "noremap <localleader><localleader> :noh<CR>")
(vim.cmd "noremap <leader><leader> : ")

; Open terminal quickly
(vim.cmd "noremap <localleader>ts :split term://bash<CR>")
(vim.cmd "noremap <localleader>tv :vsplit term://bash<CR>")
(vim.cmd "noremap <localleader>tt :term bash<CR>")

; Clipboard stuff
(vim.cmd "noremap <leader>xp :normal! \"+p<CR>") 
(vim.cmd "vnoremap <leader>xy :'<'>normal! \"+y<CR>")
