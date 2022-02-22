(local Vimhelp {})
(local utils (require :utils))
(local str (require :aniseed.string))
(local core (require :aniseed.core))

; Add a Tabular pattern
(fn Vimhelp.add-sep []
  (let [tw (if (= 0 vim.bo.textwidth)
             78 
             vim.bo.textwidth)
        sep (string.rep "=" tw)
        [row _] (utils.pos)]
    (set vim.bo.textwidth tw)
    (utils.set-lines 0 [row row] sep)))

(fn Vimhelp.adjust-sep []
  (let [tw (if (= 0 vim.bo.textwidth)
             78
             vim.bo.textwidth)
        sep (string.rep "=" tw)]
    (vim.cmd "normal! mz")
    (vim.cmd (utils.fmt ":%%s/^=\\{3,\\}/%s" sep))
    (vim.cmd "noh")
    (vim.cmd "normal! 'z")
    (vim.cmd "normal! dmz")))

(fn Vimhelp.setup [] 
  (utils.define-keys [{:keys "<C-f>"
                       :key-attribs "buffer"
                       :exec "/^=\\{3,\\}<CR><esc>:noh<CR>"
                       :help "Jump to next section"
                       :patterns ["*txt,*text"]
                       :events "BufEnter"}

                      {:keys "<C-b>"
                       :key-attribs "buffer"
                       :exec "?^=\\{3,\\}<CR><esc>:noh<CR>"
                       :help "Jump to prev section"
                       :patterns ["*txt,*text"]
                       :events "BufEnter"}

                      {:keys "-" 
                       :help "Add separator based on textwidth"
                       :key-attribs ["buffer"]
                       :events ["BufEnter"]
                       :patterns ["*txt,*text"]
                       :exec Vimhelp.add-sep}

                      {:keys "+" 
                       :help "Readjust the width of sep across the buffer"
                       :events ["BufEnter"]
                       :key-attribs ["buffer"]
                       :patterns ["*txt,*text"]
                       :exec Vimhelp.adjust-sep}

                      {:keys "<C-p>"
                       :exec "?<bar>[^<bar>]*<bar><CR><esc>:noh<CR>"
                       :key-attribs ["buffer"]
                       :events ["BufEnter"]
                       :patterns ["*txt,*text"]
                       :help "Goto prev url"}

                      {:keys "<C-n>"
                       :exec "/<bar>[^<bar>]*<bar><CR><esc>:noh<CR>"
                       :key-attribs ["buffer"]
                       :events ["BufEnter"]
                       :patterns ["*txt,*text"]
                       :help "Goto next url"}

                      {:keys "<A-b>"
                       :help "Goto prev tag"
                       :key-attribs ["buffer"]
                       :events ["BufEnter"]
                       :patterns ["*txt,*text"]
                       :exec "?\\*[^*]*\\*<CR><esc>:noh<CR>"}

                      {:keys "<A-f>"
                       :help "Goto next tag"
                       :key-attribs ["buffer"]
                       :events ["BufEnter"]
                       :patterns ["*txt,*text"]
                       :exec "/\\*[^*]*\\*<CR><esc>:noh<CR>"}]))

Vimhelp
