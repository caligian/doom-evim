(module configs
  {autoload {utils utils}})

; Very doom-emacs-esque after!
(local after! _G.after!)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; nvim-tree
(after! :nvim-tree.lua
        (fn []
          ((. (require :nvim-tree) :setup))
          (vim.cmd "noremap <leader>` :NvimTreeToggle<CR>")))

; vim-sexp
(after! :vim-sexp
        (fn []
          (set vim.g.sexp_filetypes (table.concat doom.lisp_langs ","))))

; delimitMate
(after! :delimitMate
        (fn []
          (set vim.g.delimitMate_excluded_ft (table.concat doom.lisp_langs ","))))

; vimspector
(after! :vimspector (fn []
                      (vim.cmd "packadd! vimspector")
                      (vim.cmd "nnoremap <Leader>dd :call vimspector#Launch()<CR>")
                      (vim.cmd "nnoremap <Leader>de :call vimspector#Reset()<CR>")
                      (vim.cmd "nnoremap <Leader>dc :call vimspector#Continue()<CR>")
                      (vim.cmd "nnoremap <Leader>dt :call vimspector#ToggleBreakpoint()<CR>")
                      (vim.cmd "nnoremap <Leader>dT :call vimspector#ClearBreakpoints()<CR>")
                      (vim.cmd "nmap <Leader>dk <Plug>VimspectorRestart")
                      (vim.cmd "nmap <Leader>dh <Plug>VimspectorStepOut")
                      (vim.cmd "nmap <Leader>dl <Plug>VimspectorStepInto")
                      (vim.cmd "nmap <Leader>dj <Plug>VimspectorStepOver")))

(after! :persistence (fn []
                       (let [persistence (require :persistence)
                             save-dir (.. (vim.fn.stdpath "data") "/sessions/")]
                         (persistence.setup {:dir save-dir}))))

(after! :trouble.nvim
        (fn []
          (let [trouble (require :trouble)]
            (trouble.setup)
            (vim.cmd "noremap <leader>lt :TroubleToggle<CR>"))))

(after! :dashboard-nvim (fn []
                          (set vim.g.indentLine_fileTypeExclude [:dashboard])
                          (set vim.g.dashboard_custom_header (vim.split "
                 °*oO##@@@@@@@@##Oo*°
             .*O#@@@@@@@@@@@@@@@@@@@@#Oo°
           °O@@@@#####@@@@@@@@@@#####@@@@#o°
         *#@@@###@@@@@@@@@@@@@@@@@@@@####@@@O°
       .#@@##@@@@@@@@@@@@@@@@@@@@@@@@@@@@###@@o
       O@###@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@###@o
       #@@@@#####@@@@@@@@@@@@@@@@@@@@@####@@@##@
      .#####@@@@@####@@@@@@@@@@@@@####@@@@@##@@#
       ooo. .*oO#@@@@@############@@@@#O*°.  ***
       #@@o      °*o#@@@@@@@@@@@@@#O*.      °##°
       °@@@o.         °*O#####Oo°.        .*@@O
        °O#@##Ooo**°°°**O#OOO#Oo*°°°°**oO##@#@°
         .O#@@@@@@@@@@@@@o.#**@@@@@@@@@@@@@##O
         ######@@###@@##o o@O *#@@##@#######@#
         O@@@@@o°.  OOooO#@#@#OOo#@@o    #@@#*
          **°°*°    o##@@@#@#@@oOooO     **°
                    o@@###@°O#O°@@#°
                    .@@OO@@.o@oo@#O
                    .#@Oo@@.o@oo@@o
                     #@O*@@.o@oo@@o
                     ##O*@@.o@*o@#*
                     O@O*@@.o@°o@@.
                     °Oo°@@.o# o#o

                        E V I M"  "\n"))

                          (vim.cmd "noremap <leader>sl :SessionLoad")
                          (vim.cmd "noremap <leader>ss :SessionSave<CR>")
                          (set vim.g.dashboard_default_executive "telescope")
                          (set vim.g.dashboard_custom_section {:a {:description   ["  Load Session                        SPC s l"]
                                                                   :command "lua require('persistence').load({last=true})"}
                                                               :b {:description   ["  Recently Opened Files               SPC f r"]
                                                                   :command  "Telescope oldfiles"}
                                                               :c {:description   ["  Change colorscheme                  SPC h t"]
                                                                   :command  "Telescope colorscheme"}
                                                               :d {:description   ["  Split window with terminal          COM t s"]
                                                                   :command ":REPLSplitShell"}
                                                               :e {:description   ["  Find File                           SPC f f"]
                                                                   :command  "Telescope find_files"}
                                                               :f {:description   ["  Open system configuration           SPC f p"]
                                                                   :command ":Dirbuf ~/.vdoom.d/"}
                                                               :g {:description   ["  Open private configuration          SPC f P"]
                                                                   :command ":Dirbuf ~/.vdoom.d/"}})))
; undotree
(after! :undotree
        (fn []
          (set vim.g.undotree_SetFocusWhenToggle 1)))

; formatter
; Stolen from doom-nvim
(after! :formatter.nvim
              (fn []
                (let [format (require :formatter)]
                  (vim.cmd "noremap <silent> <leader>mf :Format <CR>")
                  (format.setup {"*" {:cmd ["sed -i 's/[ \t]*$//'"]}

                                 :vim {:cmd [#(utils.fmt "stylua --config-path %s/.config/stylua/stylua.toml %s" (os.getenv :HOME) $1)]}

                                 :vimwiki {:cmd ["prettier -w --parser babel"]}

                                 :lua {:cmd [#(utils.fmt "stylua --config-path %s/.config/stylua/stylua.toml %s" (os.getenv :HOME) $1)]}

                                 :python {:cmd [#(utils.fmt "yapf -i %s" $1)]}

                                 :go {:cmd ["gofmt -w" "goimports -w"]
                                      :tempfile_postfix ".tmp"}

                                 :javascript {:cmd ["prettier -w"
                                                    "./node_modules/.bin/eslient --fix"]}

                                 :typescript {:cmd ["prettier -w --parser typescript"]}

                                 :html {:cmd ["prettier -w --parser html"]}

                                 :markdown {:cmd ["prettier -w --parser markdown"]}

                                 :css {:cmd ["prettier -w --parser css"]}

                                 :scss {:cmd ["prettier -w --parser scss"]}

                                 :json {:cmd ["prettier -w --parser json"]}

                                 :toml {:cmd ["prettier -w --parser toml"]}

                                 :yaml {:cmd ["prettier -w --parser yaml"]}}))))

; zen-mode
(after! :zen-mode.nvim #(vim.cmd "noremap <leader>bz :ZenMode<CR>"))

; treesitter
(after! :nvim-treesitter
        (fn []
          (let [treesitter-configs (require "nvim-treesitter.configs")]
            (treesitter-configs.setup {:ensure_installed doom.treesitter-langs
                                       :sync_install true
                                       :highlight {:enable true}
                                       :indent {:enable true}}))))

; vim-bbye
(after! :vim-bbye
        (fn []
          (vim.cmd "noremap <leader>bk :Bdelete<CR>")))

; file pickers
(after! :telescope.nvim
        (fn []
          (let [telescope (require :telescope)
                actions (require :telescope.actions)]
            (telescope.setup {:defaults {:path_display [:smart]
                                         :mappings {:n {:D actions.delete_buffer}
                                                    :i {"<C-d>" actions.delete_buffer}}}})

            ; Add some more default actions
            (vim.cmd "noremap <leader>ff :lua require('telescope.builtin').find_files(require('telescope.themes').get_ivy())<CR>")
            (vim.cmd "noremap <localleader>/ :lua require('telescope.builtin').live_grep(require('telescope.themes').get_ivy())<CR>")
            (vim.cmd "noremap <leader>/  :lua require('telescope.builtin').grep_string(require('telescope.themes').get_ivy())<CR>")
            (vim.cmd "noremap <leader>fg :lua require('telescope.builtin').git_files(require('telescope.themes').get_ivy())<CR>")
            (vim.cmd "noremap  <leader>hk :lua require('telescope.builtin').keymaps(require('telescope.themes').get_ivy())<CR>")
            (vim.cmd "noremap  <leader>ht :lua require('telescope.builtin').colorscheme(require('telescope.themes').get_ivy())<CR>")
            (vim.cmd "noremap  <leader>bb :lua require('telescope.builtin').buffers(require('telescope.themes').get_ivy())<CR>")
            (vim.cmd "noremap  <leader>fr :lua require('telescope.builtin').oldfiles(require('telescope.themes').get_ivy())<CR>")
            (vim.cmd "noremap  <A-x> :lua require('telescope.builtin').commands(require('telescope.themes').get_ivy())<CR>")
            (vim.cmd "noremap  <leader>hr :lua require('telescope.builtin').command_history(require('telescope.themes').get_ivy())<CR>")
            (vim.cmd "noremap  <leader>sr :lua require('telescope.builtin').search_history(require('telescope.themes').get_ivy())<CR>")
            (vim.cmd "noremap  <leader>hm :lua require('telescope.builtin').man_pages(require('telescope.themes').get_ivy())<CR>")
            (vim.cmd "noremap  <leader>hj :lua require('telescope.builtin').jumplist(require('telescope.themes').get_ivy())<CR>")
            (vim.cmd "noremap  <leader>h  :lua require('telescope.builtin').registers(require('telescope.themes').get_ivy())<CR>")
            (vim.cmd "noremap  <M-y>      :lua require('telescope.builtin').registers(require('telescope.themes').get_ivy())<CR>")
            (vim.cmd "noremap <leader><leader>s :lua require('telescope.builtin').resume(require('telescope.themes').get_ivy())<CR>")
            (vim.cmd "noremap <leader>hq :lua require('telescope.builtin').quickfix(require('telescope.themes').get_ivy())<CR>")

            ; LSP
            (vim.cmd "noremap <leader>lhr :lua require('telescope.builtin').lsp_references(require('telescope.themes').get_ivy())<CR>")
            (vim.cmd "noremap <leader>lhs :lua require('telescope.builtin').lsp_document_symbols(require('telescope.themes').get_ivy())<CR>")
            (vim.cmd "noremap <leader>lhw :lua require('telescope.builtin').lsp_workspace_symbols(require('telescope.themes').get_ivy())<CR>")
            (vim.cmd "noremap <leader>lhW :lua require('telescope.builtin').lsp_dynamic_workspace_symbols(require('telescope.themes').get_ivy())<CR>")
            (vim.cmd "noremap <leader>lhc :lua require('telescope.builtin').lsp_code_actions(require('telescope.themes').get_ivy())<CR>")
            (vim.cmd "noremap <leader>lhr :lua require('telescope.builtin').lsp_range_code_actions(require('telescope.themes').get_ivy())<CR>")
            (vim.cmd "noremap <leader>lhd :lua require('telescope.builtin').lsp_diagnostics(require('telescope.themes').get_ivy())<CR>")
            (vim.cmd "noremap <leader>lhi :lua require('telescope.builtin').lsp_implementations(require('telescope.themes').get_ivy())<CR>")
            (vim.cmd "noremap <leader>lhd :lua require('telescope.builtin').lsp_definitions(require('telescope.themes').get_ivy())<CR>")
            (vim.cmd "noremap <leader>lht :lua require('telescope.builtin').lsp_type_definitions(require('telescope.themes').get_ivy())<CR>")

            ; Treesitter
            (vim.cmd "noremap <leader>mhs :lua require('telescope.builtin').treesitter(require('telescope.themes').get_ivy())<CR>")

            ; Git
            (vim.cmd "noremap <leader>ghc :lua require('telescope.builtin').git_commits(require('telescope.themes').get_ivy())<CR>")
            (vim.cmd "noremap <leader>ghC :lua require('telescope.builtin').git_bcommits(require('telescope.themes').get_ivy())<CR>")
            (vim.cmd "noremap <leader>ghb :lua require('telescope.builtin').git_branches(require('telescope.themes').get_ivy())<CR>")
            (vim.cmd "noremap <leader>ghs :lua require('telescope.builtin').git_status(require('telescope.themes').get_ivy())<CR>")
            (vim.cmd "noremap <leader>ghS :lua require('telescope.builtin').git_stash(require('telescope.themes').get_ivy())<CR>")

            ; Load file browser
            (telescope.load_extension "file_browser")
                      (vim.cmd "noremap <leader>fF :lua require('telescope').extensions.file_browser.file_browser(require('telescope.themes').get_ivy())<CR>")

            (after! :telescope-project.nvim
                    (fn []
                      (telescope.load_extension "project")
                      (vim.cmd "noremap <C-p> :lua require('telescope').extensions.project.project(require('telescope.themes').get_ivy())<CR>"))))))

; vim-palette: Colorscheme provider
(after! :vim-palette
       (fn []
          (vim.cmd "colorscheme one")))

; galaxyline
(after! :galaxyline.nvim
              (fn []
                (require :modeline)))

; Tagbar
(after! :tagbar
        (fn []
          (vim.cmd "noremap <C-t> :TagbarToggle<CR>")))

; nvim-cmp
(after! :nvim-cmp
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
(after! :vim-fugitive
        (fn []
          (vim.cmd  "noremap <leader>gg :Git<CR>")
          (vim.cmd  "noremap <leader>gi :Git init<CR>")
          (vim.cmd  "noremap <leader>ga :Git add %<CR>")
          (vim.cmd  "noremap <leader>gs :Git stage %<CR>")
          (vim.cmd  "noremap <leader>gc :Git commit %<CR>")
          (vim.cmd  "noremap <leader>gp :Git push<CR>")
          (vim.cmd  "noremap <leader>gm :Git merge<CR>")))

; Luapad
(after! :nvim-luapad
        (fn []
          (vim.cmd  "noremap <F3> :Luapad<CR>")))

; vimp
(after! :vimpeccable
        (fn []
          (let [vimp (require :vimp)]
            (vimp.add_chord_cancellations "n" "<leader>")
            (vimp.add_chord_cancellations "n" "<localleader>"))))

; which-key
(after! :which-key.nvim
        (fn []
          (let [wk (require :which-key)]
            (wk.setup {:key_labels {"<space>" "SPC"
                                    "<cr>" "RET"
                                    "<tab>" "TAB"}}))))

; pytest
(after! :pytest.vim
        (fn []
          (set vim.g.pytest_executable "pytest")))

; Ruby stuff
; vroom
(after! :vim-vroom
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

; vim-bbye
(after! :vim-bbye
        (fn []
          (vim.cmd "noremap <leader>bq :Bdelete<CR>")))

; Tagbar
(after! :tagbar
        (fn []
          (vim.cmd "noremap <C-t> :TagbarToggle<CR>")))

; which-key
(after! :which-key.nvim
        (fn []
          (let [wk (require :which-key)]
            (wk.setup {:key_labels {"<space>" "SPC"
                                    "<cr>" "RET"
                                    "<tab>" "TAB"}}))))

; vim-dispatch
(after! :vim-dispatch
        (fn []
          (utils.add-hook "GlobalHook" "FileType" "ruby" "let b:dispatch = 'ruby %'")
          (utils.add-hook "GlobalHook" "FileType" "lua" "let b:dispatch = 'lua %'")
          (utils.add-hook "GlobalHook" "FileType" "python" "let b:dispatch = 'perl %'")
          (utils.add-hook "GlobalHook" "FileType" "sh" "let b:dispatch = 'bash %'")
          (utils.add-hook "GlobalHook" "FileType" "perl" "let b:dispatch = 'perl %'")))

; vim-session
(after! :vim-session
        (fn []
          (set vim.g.session_directory "~/.config/nvim/sessions")))
; ultisnips
(after! [:ultisnips
               :vim-snippets]
              (fn []
                (vim.cmd "let g:UltiSnipsExpandTrigger='<tab>'")
                (vim.cmd "let g:UltiSnipsJumpForwardTrigger='<C-j>'")
                (vim.cmd "let g:UltiSnipsJumpBackwardTrigger='<C-k>'")
                (vim.cmd "let g:UltiSnipsEditSplit='vertical'")))

(after! :dirbuf.nvim
              (fn []
                (vim.cmd "noremap <leader>fd :Dirbuf<CR>")
                (vim.cmd "noremap <leader>fD :execute('Dirbuf ' . input('Directory % '))<CR>")))
