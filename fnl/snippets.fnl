(local Snippet {})
(local utils (require :utils))
(local core (require :aniseed.core))

(fn Snippet.setup []
  ; All the user snippets will go in ~/.local/share/nvim/user-snippets/
  (set vim.g.vsnip_snippet_dir (utils.datap "user-snippets"))
                      {:keys "<leader>&ts"
                       :help "Edit new template in split"
                       :exec #(let [ft vim.bo.filetype
                                    bufname (.. "_new_template_" ft)]
                                (utils.open-temp-input-buffer bufname :sp ft))}
                      


  ; Open a new split/vsplit window and set buffer props
  (utils.define-key {:keys "<leader>&sv"
                     :help "Edit new snippet in vsplit"
                     :exec #(let [ft vim.bo.filetype
                                  bufname (.. "_new_snippet_" ft)]
                              (utils.open-temp-input-buffer bufname :vsp ft))})

  (utils.define-key {:keys "<leader>&ss"
                     :help "Edit new snippet in split"
                     :exec #(let [ft vim.bo.filetype
                                  bufname (.. "_new_snippet_" ft)]
                              (utils.open-temp-input-buffer bufname :sp ft))})

  
  ; Get the string from the buffer and save the snippet
  (utils.define-key {:keys "gx"
                     :key-attribs "buffer"
                     :patterns "_new_snippet_*"
                     :events "BufEnter"
                     :exec (fn []
                             (let [s (utils.buffer-string (vim.call :winbufnr 0) [0 -1] false)]
                               (if (and (= 1 (length s))
                                        (= (. s 1) ""))
                                 false
                                 (let [name (utils.get-user-input "Snippet name > " #(~= $1 "") true)
                                       dest-dir (utils.datap "doom-snippets")
                                       fname (utils.datap "doom-snippets" (.. vim.bo.filetype ".json"))
                                       prefix (utils.get-user-input "Snippet prefix > " #(~= $1 "") true)
                                       json {}]

                                   (tset json name {:prefix [prefix] :body s})

                                   (when (not (utils.path-exists dest-dir))
                                     (utils.sh (.. "mkdir " dest-dir)))

                                   (if (not (utils.path-exists fname))
                                     (core.spit fname (vim.call :json_encode json)))

                                   (let [_file (core.slurp fname)
                                         file (if (not (string.match _file "[{}]"))
                                                {}
                                                _file)
                                         current-json (vim.call :json_decode (core.slurp fname))
                                         new-json (vim.tbl_extend :force current-json json)]
                                     (core.spit fname (vim.call :json_encode new-json)))
                                   ))))})
  ; Some keybindings for vsnip
  (utils.define-keys [{:keys "<leader>&sev"
                       :exec ":VsnipOpenVsplit<CR>"
                       :help "Open a snippets json in vsplit"}

                      {:keys "<leader>&ses"
                       :exec ":VsnipOpenSplit<CR>"
                       :help "Open a snippets json in split"}]))

Snippet
