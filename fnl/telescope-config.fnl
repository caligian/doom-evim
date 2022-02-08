(module telescope-config)

(let [telescope (require :telescope)
      actions (require :telescope.actions)
      utils (require :utils)]

  ; Some stuff was stolen from NvChad

  (telescope.load_extension "file_browser")
  (telescope.load_extension "fzf")
  (telescope.load_extension "project")
  (telescope.setup {:extensions {:fzf {:fuzzy true
                                       :override_generic_sorter true
                                       :override_file_sorted true
                                       :case_mode "smart_case"}}
                    :defaults {:vimgrep_arguments [:rg
                                                   "--color=never"
                                                   "--no-heading"
                                                   "--with-filename"
                                                   "--line-number"
                                                   "--column"
                                                   "--smart-case"]

                               :layout_strategy "horizontal"
                               :layout_config {:horizontal {:prompt_position "top"
                                                            :preview_width 0.55
                                                            :results_width 0.8}
                                               :vertical {:mirror false}
                                               :width 0.87
                                               :height 0.80
                                               }

                               :preview false
                               :path_display [:smart]
                               :mappings {:n {:D actions.delete_buffer}
                                          :i {"<C-d>" actions.delete_buffer}}}})
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
                       :exec #(vim.cmd ":lua require('telescope.builtin').colorscheme(require('telescope.themes').get_ivy())")
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

{:keys "<leader>pp"
 :exec ":lua require('telescope').extensions.project.project(require('telescope.themes').get_ivy())<CR>"
 :help "Open project"}

{:keys "<leader>fF"
 :exec ":lua require'telescope'.extensions.file_browser.file_browser(require('telescope.themes').get_ivy()) <CR>"
 :help "Open file browser"}]))
