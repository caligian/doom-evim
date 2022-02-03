(module snippets
  {autoload {utils utils
             core aniseed.core}})

; All the user snippets will go in ~/.local/share/nvim/user-snippets/
(set vim.g.vsnip_snippet_dir (utils.datap "user-snippets"))

; Open a new split/vsplit window and set buffer props
(utils.define-key {:keys "<leader>&ns"
                   :exec (fn []
                           (let [current-ft vim.bo.filetype]
                             (vim.cmd ":split _new_snippet | :wincmd k")
                             (set vim.bo.buftype "nofile")
                             (set vim.bo.buflisted false)
                             (set vim.bo.filetype current-ft)))})

(utils.define-key {:keys "<leader>&nv"
                   :exec (fn []
                           (let [current-ft vim.bo.filetype]
                             (vim.cmd ":vsplit _new_snippet | :wincmd k")
                             (set vim.bo.buftype "nofile")
                             (set vim.bo.buflisted false)
                             (set vim.bo.filetype current-ft)))})

; Get the string from the buffer and save the snippet
(utils.define-key {:keys "gx"
                   :key-attribs "buffer"
                   :patterns "_new_snippet"
                   :events "BufEnter"
                   :exec (fn []
                           (let [s (utils.buffer-string (vim.call :winbufnr 0) [0 -1] false)]
                             (if (and (= 1 (length s))
                                      (= (. s 1) ""))
                               false
                               (let [name (utils.get-user-input "Snippet name > " #(~= $1 "") true)
                                     dest-dir (utils.datap "user-snippets")
                                     fname (utils.datap "user-snippets" (.. vim.bo.filetype ".json"))
                                     prefix (utils.get-user-input "Snippet prefix > " #(~= $1 "") true)
                                     json {}]

                                 (tset json name {:prefix [prefix] :body s})

                                 (when (not (utils.path-exists dest-dir))
                                   (utils.sh (.. "mkdir " dest-dir)))

                                 (if (not (utils.path-exists fname))
                                   (core.spit fname (vim.call :json_encode json))
                                   (let [_file (core.slurp fname)
                                         file (if (not (string.match _file "[{}]"))
                                                {}
                                                _file)
                                         current-json (vim.call :json_decode (core.slurp fname))
                                         new-json (vim.tbl_extend :force current-json json)]
                                     (core.spit fname (vim.call :json_encode new-json))))))))})

; Some keybindings for vsnip
(utils.define-keys [{:keys "<leader>&ev"
                     :exec ":VsnipOpenVsplit<CR>"
                     :help "Open a snippets json in vsplit"}

                    {:keys "<leader>&es"
                     :exec ":VsnipOpenSplit<CR>"
                     :help "Open a snippets json in split"}])