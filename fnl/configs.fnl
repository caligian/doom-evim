(local utils (require :utils))
(local core (require :aniseed.core))
(local after! _G.after!)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; git-signs
(after! :vim-bookmarks #(do 
                          (set vim.g.bookmark_save_per_working_dir 1)
                          (set vim.g.bookmark_auto_save 1)))

(after! :gitsigns.nvim
        #((. (require :gitsigns) :setup)))

(after! :neorg #(require :configs.neorg-config))

(after! :conjure #(vim.cmd "let g:conjure#client#hy#stdio#command = 'hy'"))

(after! :vim-vsnip #(require :configs.vim-vsnip-config))

(after! :vim-qf (fn []
                  (utils.define-key {:keys "<leader>qf"
                                     :noremap false
                                     :help "Toggle qflist"
                                     :exec "<Plug>(qf_qf_toggle)"})
                  (set vim.g.qf_mapping_ack_style 1)))

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
          (set vim.g.delimitMate_excluded_ft (table.concat doom.lisp_langs ",")))
        100)

; vimspector
(after! :vimspector 
        #(vim.cmd "packadd! vimspector")
        100)

(after! :persistence.nvim (fn []
                            (let [persistence (require :persistence)
                                  save-dir (.. (vim.fn.stdpath "data") "/sessions/")]

                              (utils.define-keys [{:keys "<leader>sl"
                                                   :exec ":lua require('persistence').load()<CR>"
                                                   :help "Load session"}

                                                  {:keys "<leader>sL"
                                                   :exec ":lua require('persistence').load({last=true})<CR>"
                                                   :help "Load last session"}

                                                  {:keys "<leader>ss"
                                                   :exec ":lua require('persistence').save()<CR>"
                                                   :help "Save current session"}])

                              (persistence.setup {:dir save-dir}))))

(after! :trouble.nvim
        (fn []
          (let [trouble (require :trouble)]
            (trouble.setup)
            (utils.define-key {:keys "<leader>lt"
                               :exec ":TroubleToggle<CR>"
                               :help "Toggle trouble"})))
        300)

(after! :dashboard-nvim (fn []
                          (let [banner (core.slurp (utils.confp "misc" "punisher-logo.txt"))
                                banner (utils.split banner "\n")]
                            (set vim.g.dashboard_custom_footer [ (.. " " (length (utils.keys doom.packages)) " packages loaded.")])
                            (set vim.g.dashboard_custom_header banner)
                            (set vim.g.indentLine_fileTypeExclude [:dashboard])
                            (set vim.g.dashboard_default_executive "telescope")
                            (set vim.g.dashboard_custom_section {:a {:description   ["  Load previous session               SPC s l"]
                                                                     :command "lua require('persistence').load({last=true})"}
                                                                 :b {:description   ["  Recently Opened Files               SPC f r"]
                                                                     :command  "lua require('telescope.builtin').oldfiles(require('telescope.themes').get_ivy())"}
                                                                 :c {:description   ["  Change colorscheme                  SPC h t"]
                                                                     :command "lua require('telescope.builtin').colorscheme(require('telescope.themes').get_ivy())"}
                                                                 :d {:description   ["  Split window with terminal          COM t s"]
                                                                     :command ":REPLSplitShell"}
                                                                 :e {:description   ["  Find File                           SPC f f"]
                                                                     :command  "lua require('telescope.builtin').find_files(require('telescope.themes').get_ivy())"}
                                                                 :f {:description   ["  Open system configuration           SPC f p"]
                                                                     :command ":e ~/.vdoom.d/"}
                                                                 :g {:description   ["  Open private configuration          SPC f P"]
                                                                     :command ":e ~/.vdoom.d/"}}))))

; undotree
(after! :undotree
        (fn []
          (set vim.g.undotree_SetFocusWhenToggle 1)))

; zen-mode
(after! :zen-mode.nvim
        #(utils.define-key {:keys "<leader>bz" :help "Activate ZenMode" :exec ":ZenMode<CR>"})
        100)

; treesitter
(after! :nvim-treesitter
        (fn []
          (let [treesitter-configs (require "nvim-treesitter.configs")]
            (treesitter-configs.setup {:ensure_installed doom.treesitter_langs
                                       :sync_install true
                                       :highlight {:enable true}
                                       :indent {:enable true}}))))

(after! [:telescope.nvim 
         :telescope-project.nvim 
         :telescope-vim-bookmarks.nvim
         :telescope-file-browser.nvim 
         :telescope-fzf-native.nvim]
        #(do 
           (require :configs.telescope-config)

           (let [tscope-font-switcher (require :telescope-font-switcher)]
             (tscope-font-switcher.setup))))

(after! :nvim-treesitter-textobjects
        #(require :configs.nvim-treesitter-textobjects-config)
        100)

; Tagbar
(after! :tagbar
        (fn []
          (utils.define-key {:keys "<C-t>"
                             :help "Open Tagbar"
                             :exec ":TagbarToggle<CR>"}))
        100)

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
          (vim.cmd "highlight! CmpItemKindKeyword guibg=NONE guifg=#D4D4D4"))
        100)

;  vim-fugitive
(after! :vim-fugitive
        (fn []
          (utils.define-keys [{:keys "<leader>gg" :exec ":Git<CR>" :help "Open Fugitive in cwd"}
                              {:keys "<leader>gi" :exec ":Git init<CR>" :help "Initialize git in cwd"}
                              {:keys "<leader>ga" :exec ":Git add %<CR>" :help "Track current file"}
                              {:keys "<leader>gs" :exec ":Git stage %<CR>" :help "Stage current file"}
                              {:keys "<leader>gc" :exec ":Git commit %<CR>" :help "Commit changes"}
                              {:keys "<leader>gp" :exec ":Git push<CR>" :help "Push commits"}
                              {:keys "<leader>gm" :exec ":Git merge<CR>" :help "Merge from remote"}]))
        200)

; Luapad
(after! :nvim-luapad
        (fn []
          (utils.define-key {:keys "<F3>" :exec ":Luapad<CR>" :help "Start Luapad"}))
        100)

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
