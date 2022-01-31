(module vim-help
  {autoload {utils utils
             str aniseed.string
             core aniseed.core}})

(defn- add-sep []
  (let [tw (if (= 0 vim.bo.textwidth)
             78 
             vim.bo.textwidth)
        sep (string.rep "=" tw)
        [row _] (utils.pos)]
    (set vim.bo.textwidth tw)
    (utils.set-lines 0 [row] sep)))

(defn- convert-to-tag []
  (vim.cmd "normal! EBi*")
  (vim.cmd "normal! Ea*"))

(defn- convert-to-url []
  (vim.cmd "normal! EBi|")
  (vim.cmd "normal! Ea|"))

(utils.define-keys [{:keys "<leader>i-" 
                     :help "Add separator based on textwidth"
                     :events ["BufEnter"]
                     :patterns ["*txt,*text"]
                     :exec add-sep}

                    {:keys "<leader>iu"
                     :help "Convert current word to url"
                     :events ["BufEnter"]
                     :patterns ["*txt,*text"]
                     :exec convert-to-url}
                    
                    {:keys "<leader>it"
                     :help "Convert current word to tag"
                     :events ["BufEnter"]
                     :patterns ["*txt,*text"]
                     :exec convert-to-tag}])
