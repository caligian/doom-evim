(module formatter
  {autoload {str aniseed.string
             utils utils}})

(utils.define-key {:keys "<leader>mf"
                   :help "Format the current buffer"
                   :exec (fn []
                           (let [formatter (?. doom.langs vim.bo.filetype :format)
                                 manual (?. doom.langs vim.bo.filetype :format-write)
                                 current-file (vim.fn.expand "%:p")
                                 cmd (when formatter
                                       (if manual
                                         (utils.fmt ":! out=$(%s %s); [[ $(cat %s | wc -w) -ne 0 ]] && echo -e \"$out\" > %s"
                                                    formatter 
                                                    current-file
                                                    current-file
                                                    current-file)
                                         (utils.fmt ":! %s %s" formatter current-file)))]
                             (when cmd 
                               (vim.cmd cmd))))})
