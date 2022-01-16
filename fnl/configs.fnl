(module configs
  {autoload {utils utils}})

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; undotree
(utils.after! :undotree 
        (fn []
          (set vim.g.undotree_SetFocusWhenToggle 1)))

; treesitter
(utils.after! :nvim-treesitter
        (fn []
          (let [treesitter-configs (require "nvim-treesitter.configs")]
            (local treesitter-langs   [:python 
                                       :yaml 
                                       :json
                                       :javascript 
                                       :c 
                                       :lua 
                                       :perl 
                                       :ruby])
            (treesitter-configs.setup {:ensure_installed treesitter-langs
                                       :sync_install true
                                       :highlight {:enable true}
                                       :indent {:enable true}}))))

; vim-bbye
(utils.after! :vim-bbye 
        (fn [] 
          (vim.cmd "noremap <leader>bk :Bdelete<CR>")))

; file pickers
(utils.after! :telescope.nvim
        (fn [] 
          (let [telescope (require :telescope)]
            (vim.cmd "noremap <leader>ff :lua require('telescope.builtin').find_files()<CR>")
            (vim.cmd "noremap <leader>ss :lua require('telescope.builtin').live_grep()<CR>")
            (vim.cmd "noremap <leader>/  :lua require('telescope.builtin').grep_string()<CR>")
            (vim.cmd "noremap <leader>fg :lua require('telescope.builtin').git_files()<CR>")
            (vim.cmd "noremap  <leader>hk :lua require('telescope.builtin').keymaps()<CR>")
            (vim.cmd "noremap  <leader>ht :lua require('telescope.builtin').colorscheme()<CR>")
            (vim.cmd "noremap  <leader>bb :lua require('telescope.builtin').buffers()<CR>")
            (vim.cmd "noremap  <leader>fr :lua require('telescope.builtin').oldfiles()<CR>")
            (vim.cmd "noremap  <leader>h: :lua require('telescope.builtin').commands()<CR>")
            (vim.cmd "noremap  <leader>hr :lua require('telescope.builtin').command_history()<CR>")
            (vim.cmd "noremap  <leader>sr :lua require('telescope.builtin').search_history()<CR>")
            (vim.cmd "noremap  <leader>hm :lua require('telescope.builtin').man_pages()<CR>")
            (vim.cmd "noremap  <leader>hj :lua require('telescope.builtin').jumplist()<CR>")
            (vim.cmd "noremap  <leader>h  :lua require('telescope.builtin').registers()<CR>")
            (vim.cmd "noremap  <M-y>      :lua require('telescope.builtin').registers()<CR>")

            ; Load file browser
            (telescope.load_extension "file_browser")
                      (vim.cmd "noremap <leader>fF :lua require('telescope').extensions.file_browser.file_browser()<CR>")

            (utils.after! :telescope-project.nvim
                    (fn []
                      (telescope.load_extension "project") 
                      (vim.cmd "noremap <C-p> :lua require('telescope').extensions.project.project({})<CR>"))))))

(utils.after! :awesome-vim-colorschemes
        (fn []
          (vim.cmd "color 256_noir")))

; Tagbar
(utils.after! :tagbar
        (fn []
          (vim.cmd "noremap <C-t> :TagbarToggle<CR>")))

; nvim-cmp
(utils.after! :nvim-cmp 
        (fn []
          (vim.cmd "highlight! CmpItemAbbrDeprecated guibg=NONE gui=strikethrough guifg=#808080")
          (vim.cmd "highlight! CmpItemAbbrMatch guibg=NONE guifg=#569CD6")
          (vim.cmd "highlight! CmpItemAbbrMatchFuzzy guibg=NONE guifg=#569CD6")
          (vim.cmd "highlight! CmpItemKindVariable guibg=NONE guifg=#9CDCFE")
          (vim.cmd "highlight! CmpItemKindInterface guibg=NONE guifg=#9CDCFE")
          (vim.cmd "highlight! CmpItemKindText guibg=NONE guifg=#9CDCFE")
          (vim.cmd "highlight! CmpItemKindFunction guibg=NONE guifg=#C586C0")
          (vim.cmd "highlight! CmpItemKindMethod guibg=NONE guifg=#C586C0")
          (vim.cmd "highlight! CmpItemKindKeyword guibg=NONE guifg=#D4D4D4")))

;  vim-fugitive
(utils.after! :vim-fugitive 
        (fn []
          (vim.cmd  "noremap <leader>gg :Git<CR>")
          (vim.cmd  "noremap <leader>gi :Git init<CR>")
          (vim.cmd  "noremap <leader>ga :Git add %<CR>")
          (vim.cmd  "noremap <leader>gs :Git stage %<CR>")
          (vim.cmd  "noremap <leader>gc :Git commit %<CR>")
          (vim.cmd  "noremap <leader>gp :Git push<CR>")
          (vim.cmd  "noremap <leader>gm :Git merge<CR>")))

; Luapad
(utils.after! :nvim-luapad 
        (fn []
          (vim.cmd  "noremap <F3> :Luapad<CR>")))

; vimp
(utils.after! :vimpeccable
        (fn []
          (let [vimp (require :vimp)]
            (vimp.add_chord_cancellations "n" "<leader>")
            (vimp.add_chord_cancellations "n" "<localleader>"))))

; which-key
(utils.after! :which-key.nvim
        (fn []
          (let [wk (require :which-key)]
            (wk.setup))))

; pytest
(utils.after! :pytest.vim
        (fn []
          (set vim.g.pytest_executable :pytest)

          (utils.define-keys [{:noremap true
                               :keys "<leader>mtf"
                               :modes ["n"]
                               :events ["BufEnter"]
                               :patterns ["*py"]
                               :exec ":Pytest file<CR>"
                               :help "Run pytest on current file"
                               :help-group "m"}

                              {:noremap true
                               :keys "<leader>mtc"
                               :events ["BufEnter"]
                               :modes ["n"]
                               :patterns ["*py"]
                               :exec ":Pytest class<CR>"
                               :help "Run pytest on current file"
                               :help-group "m"}

                              {:noremap true
                               :keys "<leader>mtm"
                               :events ["BufEnter"]
                               :modes ["n"]
                               :patterns ["*py"]
                               :exec ":Pytest method<CR>"
                               :help "Run pytest on current file"
                               :help-group "m"}

                              {:noremap true
                               :keys "<leader>mtp"
                               :events ["BufEnter"]
                               :modes ["n"]
                               :patterns ["*py"]
                               :exec ":execute ':Pytest ' . input('Pytest <cmd> % ')<CR>"
                               :help "Run pytest on current file"
                               :help-group "m"}

                              {:noremap true
                               :keys "<leader>mtC"
                               :modes ["n"]
                               :events ["BufEnter"]
                               :patterns ["*py"]
                               :exec ":Pytest clear<CR>"
                               :help "Run pytest on current file"
                               :help-group "m"}])))

; Ruby stuff
; vroom
(utils.after! :vim-vroom 
        (fn []
          (set vim.g.vroom_map_keys 0)
          (set vim.g.vroom_write_all 1)
          (set vim.g.vroom_use_terminal 1)

          (utils.define-keys [{:noremap true
                               :keys "<leader>mvf"
                               :modes "n"
                               :patterns "*rb"
                               :key-attribs ["buffer"]
                               :events ["WinEnter"]
                               :exec ":VroomRunTestFile<CR>"}

                              {:noremap true
                               :keys "<leader>mvn"
                               :modes "n"
                               :patterns "*rb"
                               :key-attribs ["buffer"]
                               :events ["WinEnter"]
                               :exec ":VroomRunNearestTestFile<CR>"}

                              {:noremap true
                               :keys "<leader>mvF"
                               :modes "n"
                               :patterns "*rb"
                               :key-attribs ["buffer"]
                               :events ["WinEnter"]
                               :exec ":VroomRunLastTest<CR>"}])))

; vim-dispatch 
(utils.after! :vim-dispatch 
        (fn []
          (utils.add-hook "GlobalHook" "FileType" "ruby" "let b:dispatch = 'ruby %'")
          (utils.add-hook "GlobalHook" "FileType" "lua" "let b:dispatch = 'lua %'")
          (utils.add-hook "GlobalHook" "FileType" "python" "let b:dispatch = 'perl %'")
          (utils.add-hook "GlobalHook" "FileType" "sh" "let b:dispatch = 'bash %'")
          (utils.add-hook "GlobalHook" "FileType" "perl" "let b:dispatch = 'perl %'")
          (utils.define-keys [{:keys "<leader>cm"
                               :noremap true
                               :exec ":execute(\":Make\" . input(\"Make % \"))<CR>"}

                              {:keys "<leader>cM"
                               :noremap true
                               :exec ":execute(\":Make!\" . input(\"Async Make % \"))<CR>"}

                              {:keys "<leader>cd"
                               :noremap true
                               :exec ":execute(\":Dispatch\" . input(\"Dispatch % \"))<CR>"}

                              {:keys "<leader>cD"
                               :noremap true
                               :exec ":execute(\":Dispatch!\" . input(\"Async Dispatch % \"))<CR>"}

                              {:keys "<leader>cf"
                               :noremap true
                               :exec ":execute(\":FocusDispatch\" . input(\"Focus Dispatch % \"))<CR>"}])))

(utils.after! [:ultisnips
               :vim-snippets]
              (vim.cmd "let g:UltiSnipsExpandTrigger='<tab>'")
              (vim.cmd "let g:UltiSnipsJumpForwardTrigger='<C-j>'")
              (vim.cmd "let g:UltiSnipsJumpBackwardTrigger='<C-k>'")
              (vim.cmd "let g:UltiSnipsEditSplit='vertical'"))
