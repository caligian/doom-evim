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
                                                   :exec ":lua require('persistence').load()<cr>"
                                                   :help "load session"}

                                                  {:keys "<leader>sl"
                                                   :exec ":lua require('persistence').load({last=true})<cr>"
                                                   :help "load last session"}

                                                  {:keys "<leader>ss"
                                                   :exec ":lua require('persistence').save()<cr>"
                                                   :help "save current session"}])

                              (persistence.setup {:dir save-dir}))))

(after! :trouble.nvim
        (fn []
          (let [trouble (require :trouble)]
            (trouble.setup)
            (utils.define-key {:keys "<leader>lt"
                               :exec ":troubletoggle<cr>"
                               :help "toggle trouble"})))
        300)

(after! :dashboard-nvim (fn []
                          (let [banner (core.slurp (utils.confp "misc" "punisher-logo.txt"))
                                banner (utils.split banner "\n")]
                            (set vim.g.dashboard_custom_footer [ (.. " " (length (utils.keys doom.packages)) " packages loaded.")])
                            (set vim.g.dashboard_custom_header banner)
                            (set vim.g.indentline_filetypeexclude [:dashboard])
                            (set vim.g.dashboard_default_executive "telescope")
                            (set vim.g.dashboard_custom_section {:a {:description   ["  load previous session               spc s l"]
                                                                     :command "lua require('persistence').load({last=true})"}
                                                                 :b {:description   ["  recently opened files               spc f r"]
                                                                     :command  "lua require('telescope.builtin').oldfiles(require('telescope.themes').get_ivy())"}
                                                                 :c {:description   ["  change colorscheme                  spc h t"]
                                                                     :command "lua require('telescope.builtin').colorscheme(require('telescope.themes').get_ivy())"}
                                                                 :d {:description   ["  split window with terminal          com t s"]
                                                                     :command ":replsplitshell"}
                                                                 :e {:description   ["  find file                           spc f f"]
                                                                     :command  "lua require('telescope.builtin').find_files(require('telescope.themes').get_ivy())"}
                                                                 :f {:description   ["  open system configuration           spc f p"]
                                                                     :command ":e ~/.vdoom.d/"}
                                                                 :g {:description   ["  open private configuration          spc f p"]
                                                                     :command ":e ~/.vdoom.d/"}}))))

; undotree
(after! :undotree
        (fn []
          (set vim.g.undotree_setfocuswhentoggle 1)))

; zen-mode
(after! :zen-mode.nvim
        #(utils.define-key {:keys "<leader>bz" :help "activate zenmode" :exec ":zenmode<cr>"})
        100)

; treesitter
(after! :nvim-treesitter
        (fn []
          (let [treesitter-configs (require "nvim-treesitter.configs")]
            (treesitter-configs.setup {:ensure_installed doom.treesitter_langs
                                       :sync_install true
                                       :highlight {:enable true}
                                       :indent {:enable false}}))))

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

; tagbar
(after! :tagbar
        (fn []
          (utils.define-key {:keys "<c-t>"
                             :help "open tagbar"
                             :exec ":tagbartoggle<cr>"}))
        100)

; nvim-cmp
(after! :nvim-cmp
        (fn []
          (vim.cmd "highlight! cmpitemabbrdeprecated guibg=none gui=strikethrough guifg=#808080")
          (vim.cmd "highlight! cmpitemabbrmatch guibg=none guifg=#569cd6")
          (vim.cmd "highlight! cmpitemabbrmatchfuzzy guibg=none guifg=#569cd6")
          (vim.cmd "highlight! cmpitemkindvariable guibg=none guifg=#9cdcfe")
          (vim.cmd "highlight! cmpitemkindinterface guibg=none guifg=#9cdcfe")
          (vim.cmd "highlight! cmpitemkindtext guibg=none guifg=#9cdcfe")
          (vim.cmd "highlight! cmpitemkindfunction guibg=none guifg=#c586c0")
          (vim.cmd "highlight! cmpitemkindmethod guibg=none guifg=#c586c0")
          (vim.cmd "highlight! cmpitemkindkeyword guibg=none guifg=#d4d4d4"))
        100)

;  vim-fugitive
(after! :vim-fugitive
        (fn []
          (utils.define-keys [{:keys "<leader>gg" :exec ":git<cr>" :help "open fugitive in cwd"}
                              {:keys "<leader>gi" :exec ":git init<cr>" :help "initialize git in cwd"}
                              {:keys "<leader>ga" :exec ":git add %<cr>" :help "track current file"}
                              {:keys "<leader>gs" :exec ":git stage %<cr>" :help "stage current file"}
                              {:keys "<leader>gc" :exec ":git commit %<cr>" :help "commit changes"}
                              {:keys "<leader>gp" :exec ":git push<cr>" :help "push commits"}
                              {:keys "<leader>gm" :exec ":git merge<cr>" :help "merge from remote"}]))
        200)

; luapad
(after! :nvim-luapad
        (fn []
          (utils.define-key {:keys "<f3>" :exec ":luapad<cr>" :help "start luapad"}))
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
            (wk.setup {:key_labels {"<space>" "spc"
                                    "<cr>" "ret"
                                    "<tab>" "tab"}}))))

; vim-bbye
(after! :vim-bbye
        #(utils.define-key {:keys "<leader>bq" :exec ":Bdelete<CR>" :help "Delete current buffer"}))
