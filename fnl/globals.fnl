; Create some important autocmds
(vim.cmd "augroup GlobalHook\n  autocmd!\naugroup END")
(vim.cmd "autocmd GlobalHook WinLeave _temp_output_buffer :q")

; Globals
{:fnl_config true

 ; theme
 :theme "palenight" 

 ; Lisp langs to which delimitMate will not start
 :lisp_langs ["fennel" "clojure" "scheme"]

 ; Languages to use with treesitter
 :treesitter_langs [:python :norg :fennel :yaml :json :javascript :c :lua :perl :ruby]

 ; Contains all the anonymous functions used in autocmds and keybindings
 :lambdas {}

 ; which-key queries this to get the description of <leader>[PREFIX]
 :map-help-groups {:leader {:b "Buffers"
                            :q "Buffers+Close"
                            :c "Commenting"
                            :i "Insert"
                            "<space>" "Misc"
                            :l "LSP"
                            :t "Tabs"
                            :o "Neorg"
                            :h "Help+Telescope"
                            :f "Files"
                            :p "Project"
                            :d "Debug"
                            :& "Snippets"
                            :x "Misc"
                            :m "Filetype Actions"
                            :s "Session"
                            :g "Git"}

                   :localleader {"," "REPL"
                                 "t" "REPL"
                                 "e" "REPL"}}

 ; All stuff for templates.fnl
 :templates {:extensions [:fnl :py :rb :lua :hy]
             :ft-ext-assoc {:fennel "fnl"
                            :hy "hy"
                            :python "py"
                            :ruby "rb"
                            :perl "pl"}}

 ; LSP defaults
 :lsp {:install_sumneko_lua false
       :load_default false
       :servers {:solargraph {}
                 :pyright {}}}

 ; Contains user-package declarations
 :user_packages  (require :user-packages)

 ; Only matters if fnl_config = true
 :user_compile_fnl ["init" "utils" "keybindings" "configs" "lsp-configs"]

 :repl {:ft {:sh "bash"
             :ruby "irb"
             :perl "perl"
             :fennel "fennel"
             :python "python3.9"
             :lua "lua"
             :powershell "powershell"
             :ps1 "powershell"}

        ; form: {:cmd {:id terminal_job_id :buffer bufnr}}
        :running_repls {}}

 :default_packages (require :default_packages)
 :essential_packages (require :essential_packages)

 ; Basic setup for languages
 ; Used by doom's runner
 :langs {:python {:server "pyright" 
                  :compile "python3"
                  :format "python3 -m yapf"
                  :format-write true
                  :debug "python3 -m pdb"
                  :test "pytest"
                  :build false}

         :ruby {:server "solargraph"
                :format "rubocop --fix-layout" 
                :compile "ruby"
                :debug "ruby -r debug"
                :test "rspec"
                :build "rake"}

         :fennel {:compile "fennel"}

         :sh {:compile "bash"}

         :perl {:compile "perl"}

         :javascript {:compile "node"}

         :lua {:server "sumneko_lua"
               :compile "/usr/bin/lua"
               :format "luafmt"
               :format-write true
               :manual true
               :debug "lua"
               :test "lua"
               :build false}}}

