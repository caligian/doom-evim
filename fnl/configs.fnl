(module configs
  {autoload {utils utils
             core aniseed.core}})

; Very doom-emacs-esque after!
(local after! _G.after!)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; git-signs
(after! :gitsigns.nvim
        #((. (require :gitsigns) :setup)))

; nvim-tree
(after! :nvim-tree.lua
        (fn []
          ((. (require :nvim-tree) :setup))
          (utils.define-key {:keys "<leader>`" :exec ":NvimTreeToggle<CR>" :help "Open nvim-tree" })))

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

                      (utils.define-keys [{:keys "<leader>de"
                                           :exec ":call vimspector#Reset()<CR>"
                                           :help "Reset vimspector"}

                                          {:keys "<leader>dc"
                                           :exec ":call vimspector#Continue()<CR>"
                                           :help "Continue"}

                                          {:keys "<leader>dt"
                                           :exec ":call vimspector#ToggleBreakpoint()<CR>"
                                           :help "Toggle breakpoint"}

                                          {:keys "<leader>dT"
                                           :exec ":call vimspector#ClearBreakpoints()<CR>"
                                           :help "Clear breakpoints"}

                                          {:keys "<leader>dk"
                                           :exec "<Plug>VimspectorRestart"
                                           :help "Restart vimspector"}

                                          {:keys "<leader>dh"
                                           :exec "<Plug>VimspectorStepOut"
                                           :help "Step out/finish"}

                                          {:keys "<leader>dl"
                                           :exec "<Plug>VimspectorStepInto"
                                           :help "Step in/step"}

                                          {:keys "<leader>dj"
                                           :exec "<Plug>VimspectorStepOver"
                                           :help "Step over/next"}])))

(after! :persistence.nvim (fn []
                            (let [persistence (require :persistence)
                                  save-dir (.. (vim.fn.stdpath "data") "/sessions/")]

                              (utils.define-keys [{:keys "<leader>sl"
                                                   :exec ":SessionLoad"
                                                   :help "Load session"}

                                                  {:keys "<leader>ss"
                                                   :exec ":SessionSave<CR>"
                                                   :help "Load session"}])

                              (persistence.setup {:dir save-dir}))))

(after! :trouble.nvim
        (fn []
          (let [trouble (require :trouble)]
            (trouble.setup)
            (utils.define-key {:keys "<leader>lt" 
                               :exec ":TroubleToggle<CR>" 
                               :help "Toggle trouble"}))))

(after! :dashboard-nvim (fn []
                          (let [banner (core.slurp (utils.confp "misc" "punisher-logo.txt"))
                                banner (utils.split banner "\n")]
                            (set vim.g.dashboard_custom_header banner)
                            (set vim.g.indentLine_fileTypeExclude [:dashboard])
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
                                                                     :command ":e ~/.vdoom.d/"}
                                                                 :g {:description   ["  Open private configuration          SPC f P"]
                                                                     :command ":e ~/.vdoom.d/"}}))))
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
(after! :zen-mode.nvim #(utils.define-key {:keys "<leader>bz" :help "Activate ZenMode" :exec ":ZenMode<CR>"}))

; treesitter
(after! :nvim-treesitter
        (fn []
          (let [treesitter-configs (require "nvim-treesitter.configs")]
            (treesitter-configs.setup {:ensure_installed doom.treesitter-langs
                                       :sync_install true
                                       :highlight {:enable true}
                                       :indent {:enable true}}))))

; file pickers
(after! [:telescope.nvim
         :telescope-project.nvim
         :telescope-file-browser.nvim]
        (fn []
          (let [telescope (require :telescope)
                actions (require :telescope.actions)]
            (telescope.setup {:defaults {:path_display [:smart]
                                         :mappings {:n {:D actions.delete_buffer}
                                                    :i {"<C-d>" actions.delete_buffer}}}})

            (telescope.load_extension "file_browser")
            (telescope.load_extension "project")

            ; Add some more default actions
            (utils.define-keys [{:keys "<leader>ff"
                                 :exec ":lua require('telescope.builtin').find_files(require('telescope.themes').get_ivy())<CR>"
                                 :help "Find file"}

                                {:keys "<localleader>/"
                                 :exec ":lua require('telescope.builtin').live_grep(require('telescope.themes').get_ivy())<CR>"
                                 :help "Live grep in cwd"}

                                {:keys "<leader>/"
                                 :exec ":lua require('telescope.builtin').grep_string(require('telescope.themes').get_ivy())<CR>"
                                 :help "Grep string in cwd"}

                                {:keys "<leader>fg"
                                 :exec ":lua require('telescope.builtin').git_files(require('telescope.themes').get_ivy())<CR>"
                                 :help "Show git files"}

                                {:keys "<leader>hk"
                                 :exec ":lua require('telescope.builtin').keymaps(require('telescope.themes').get_ivy())<CR>"
                                 :help "Show keymaps"}

                                {:keys "<leader>ht"
                                 :exec ":lua require('telescope.builtin').colorscheme(require('telescope.themes').get_ivy())<CR>"
                                 :help "Select theme"}

                                {:keys "<leader>bb"
                                 :exec ":lua require('telescope.builtin').buffers(require('telescope.themes').get_ivy())<CR>"
                                 :help "Show buffers"}

                                {:keys "<leader>fr"
                                 :exec ":lua require('telescope.builtin').oldfiles(require('telescope.themes').get_ivy())<CR>"
                                 :help "Show old files"}

                                {:keys "<A-x>"
                                 :exec ":lua require('telescope.builtin').commands(require('telescope.themes').get_ivy())<CR>"
                                 :help "Show commands"}

                                {:keys "<leader>hr"
                                 :exec ":lua require('telescope.builtin').command_history(require('telescope.themes').get_ivy())<CR>"
                                 :help "Show command history"}

                                {:keys "<leader>sr"
                                 :exec ":lua require('telescope.builtin').search_history(require('telescope.themes').get_ivy())<CR>"
                                 :help "Show search history"}

                                {:keys "<leader>hm"
                                 :exec ":lua require('telescope.builtin').man_pages(require('telescope.themes').get_ivy())<CR>"
                                 :help "Show man page for a program"}

                                {:keys "<leader>hj"
                                 :exec ":lua require('telescope.builtin').jumplist(require('telescope.themes').get_ivy())<CR>"
                                 :help "Show jumplist"}

                                {:keys "<leader>h\""
                                 :exec " :lua require('telescope.builtin').registers(require('telescope.themes').get_ivy())<CR>"
                                 :help "Show all registers"}

                                {:keys "<M-y>"
                                 :exec ":lua require('telescope.builtin').registers(require('telescope.themes').get_ivy())<CR>"
                                 :help "Show all registers"}

                                {:keys "<leader><leader>s"
                                 :exec ":lua require('telescope.builtin').resume(require('telescope.themes').get_ivy())<CR>"
                                 :help "Resume telescope"}

                                {:keys "<leader>hq"
                                 :exec ":lua require('telescope.builtin').quickfix(require('telescope.themes').get_ivy())<CR>"
                                 :help "Show quickfix list"}

                                ; LSP
                                {:keys "<leader>lhr"
                                 :exec ":lua require('telescope.builtin').lsp_references(require('telescope.themes').get_ivy())<CR>"
                                 :help "Show references"}

                                {:keys "<leader>lhs"
                                 :exec ":lua require('telescope.builtin').lsp_document_symbols(require('telescope.themes').get_ivy())<CR>"
                                 :help "Document symbols"}

                                {:keys "<leader>lhw"
                                 :exec ":lua require('telescope.builtin').lsp_workspace_symbols(require('telescope.themes').get_ivy())<CR>"
                                 :help "Show workspace symbols"}

                                {:keys "<leader>lhW"
                                 :exec ":lua require('telescope.builtin').lsp_dynamic_workspace_symbols(require('telescope.themes').get_ivy())<CR>"
                                 :help "Show dynamic ws symbols"}

                                {:keys "<leader>lhc"
                                 :exec ":lua require('telescope.builtin').lsp_code_actions(require('telescope.themes').get_ivy())<CR>"
                                 :help "Show code actions"}

                                {:keys "<leader>lhr"
                                 :exec ":lua require('telescope.builtin').lsp_range_code_actions(require('telescope.themes').get_ivy())<CR>"
                                 :help "Show range code actions"}

                                {:keys "<leader>lhd"
                                 :exec ":lua require('telescope.builtin').lsp_diagnostics(require('telescope.themes').get_ivy())<CR>"
                                 :help "Show diagnostics"}

                                {:keys "<leader>lhi"
                                 :exec ":lua require('telescope.builtin').lsp_implementations(require('telescope.themes').get_ivy())<CR>"
                                 :help "Show LSP implementations"}

{:keys "<leader>lhd"
 :exec ":lua require('telescope.builtin').lsp_definitions(require('telescope.themes').get_ivy())<CR>"
 :help "Show LSP definitions"}

{:keys "<leader>lht"
 :exec ":lua require('telescope.builtin').lsp_type_definitions(require('telescope.themes').get_ivy())<CR>"
 :help "Show type definitions"}

; Treesitter
{:keys "<leader>mhs"
 :exec ":lua require('telescope.builtin').treesitter(require('telescope.themes').get_ivy())<CR>"
 :help "Show treesitter symbols"}

; Git
{:keys "<leader>ghc"
 :exec ":lua require('telescope.builtin').git_commits(require('telescope.themes').get_ivy())<CR>"
 :help "Show commits"}

{:keys "<leader>ghC"
 :exec ":lua require('telescope.builtin').git_bcommits(require('telescope.themes').get_ivy())<CR>"
 :help "Show branch commits"}

{:keys "<leader>ghb"
 :exec ":lua require('telescope.builtin').git_branches(require('telescope.themes').get_ivy())<CR>"
 :help "Show branches"}

{:keys "<leader>ghs"
 :exec ":lua require('telescope.builtin').git_status(require('telescope.themes').get_ivy())<CR>"
 :help "Show status"} 

{:keys "<leader>ghS"
 :exec ":lua require('telescope.builtin').git_stash(require('telescope.themes').get_ivy())<CR>"
 :help "Show stashes"}

{:keys "<leader>fF"
 :exec ":lua require('telescope').extensions.project.project(require('telescope.themes').get_ivy())<CR>"
 :help "Open file browser"}

{:keys "<leader>pp"
 :exec ":lua require'telescope'.extensions.project.project{}<CR>"
 :help "Open project"}]))))

; vim-palette: Colorscheme provider
(after! :vim-palette
       (fn []
          (vim.cmd "colorscheme base16-solarized")))

; galaxyline
(after! :galaxyline.nvim
              (fn []
                (require :modeline)))

; Tagbar
(after! :tagbar
        (fn []
          (utils.define-key {:keys "<C-t>"
                             :help "Open Tagbar"
                             :exec ":TagbarToggle<CR>"})))

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
          (utils.define-keys [{:keys "<leader>gg" :exec ":Git<CR>" :help "Open Fugitive in cwd"}
                              {:keys "<leader>gi" :exec ":Git init<CR>" :help "Initialize git in cwd"}
                              {:keys "<leader>ga" :exec ":Git add %<CR>" :help "Track current file"}
                              {:keys "<leader>gs" :exec ":Git stage %<CR>" :help "Stage current file"}
                              {:keys "<leader>gc" :exec ":Git commit %<CR>" :help "Commit changes"}
                              {:keys "<leader>gp" :exec ":Git push<CR>" :help "Push commits"}
                              {:keys "<leader>gm" :exec ":Git merge<CR>" :help "Merge from remote"}])))

; Luapad
(after! :nvim-luapad
        (fn []
          (utils.define-key {:keys "<F3>" :exec ":Luapad<CR>" :help "Start Luapad"})))

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

; vim-bbye
(after! :vim-bbye 
        #(utils.define-key {:keys "<leader>bq" :exec ":Bdelete<CR>" :help "Delete current buffer"}))

; vim-dispatch
(after! :vim-dispatch
        (fn []
          (utils.add-hook "GlobalHook" "FileType" "ruby" "let b:dispatch = 'ruby %'")
          (utils.add-hook "GlobalHook" "FileType" "lua" "let b:dispatch = 'lua %'")
          (utils.add-hook "GlobalHook" "FileType" "python" "let b:dispatch = 'perl %'")
          (utils.add-hook "GlobalHook" "FileType" "sh" "let b:dispatch = 'bash %'")
          (utils.add-hook "GlobalHook" "FileType" "perl" "let b:dispatch = 'perl %'")))
