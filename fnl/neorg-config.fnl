(module neorg-config
  {autoload {utils utils
             org neorg}})

(org.setup {:load {:core.keybinds {:config {:default_keybinds true
                                            :neorg_leader "<Leader>"}}

                   :core.norg.concealer {}

                   :core.integrations.nvim-cmp {:config {}}

                   :core.norg.journal {:config {:workspace "journal"
                                                :strategy "flat"}}
                   :core.defaults {}

                   :core.norg.dirman {:config {:workspaces {:work "~/Work"
                                                            :journal "~/Personal/Journal"
                                                            :gtd "~/Personal/GetThingsDone"
                                                            :default_workspace "~/Personal/neorg"
                                                            :personal "~/Personal"
                                                            :diary "~/Personal/Diary"}}}}})

(defn- get-bullet-or-heading-under-point [?bufnr ?lineno]
  (let [lineno (or ?lineno (utils.linenum))
        lineno (if (~= lineno 0)
                 (- lineno 1)
                 0)
        bufnr (or ?bufnr 0)
        line (utils.get-line bufnr lineno)]
    (if line
      (let [(wt bullet bullet-type contains) (utils.grep line "^( *)(-+|~+|>+)(>)? *([^$]*)?")
            (heading hcontains) (utils.grep line "^(\\*+) *([^$]*)")]
        (if 
          bullet
          (let [single (string.match bullet "^.")
                len (length bullet)
                d {:single single
                   :base bullet
                   :type bullet-type
                   :is "bullet"
                   :whitespace wt
                   :contains contains
                   :len len}] 
            d)

          heading
          {:is "heading"
           :base heading
           :len (length heading)
           :single (utils.grep heading "\\*")
           :contains hcontains} 

          false)))))

(defn- _replace-heading-or-bullet-under-point [?bufnr ?lineno direction by]
  (let [sym (get-bullet-or-heading-under-point ?bufnr ?lineno)]
    (when sym 
      (let [by (if (= direction -1)
                 (if 
                   (= by 0)
                   0 

                   (= by sym.len)
                   0

                   (> by sym.len)
                   0 

                   (= by sym.len 1)
                   0

                   by)
                 by)]
        (if (= direction 1)
          (set sym.base (string.rep sym.single (+ by sym.len)))
          (set sym.base (string.sub sym.base (+ by 1) -1)))

        (if (= sym.is :heading)
          (.. sym.base " " sym.contains)
          (.. sym.whitespace sym.base (or sym.type "") " " sym.contains))))))

(defn- replace-heading-or-bullet-under-point [?bufnr ?lineno direction by]
  (let [lineno (or ?lineno (utils.linenum))
        bufnr (or ?bufnr 0)
        replacement (_replace-heading-or-bullet-under-point bufnr lineno direction by)]
    (if replacement
      (utils.set-lines bufnr [(- lineno 1)  lineno] [replacement]))))

(defn- insert-bullet-or-heading [?bufnr ?lineno]
  (let [linenum (or ?lineno (utils.linenum))
        linenum (- linenum 1)
        bufnr (or ?bufnr 0)
        put #(utils.set-lines bufnr [(+ linenum 1) (+ linenum 1)] [$1])]
    (let [sym (get-bullet-or-heading-under-point bufnr linenum)]
        (if (?. sym :is)
          (if (= sym.is :bullet)
            (put (utils.fmt "%s" (.. sym.whitespace sym.base (or sym.type "") " ")))
            (put (utils.fmt "%s" (.. sym.base " "))))
          (put "* ")))))

(defn- promote-bullet-or-heading [?bufnr ?lineno ?by]
  (replace-heading-or-bullet-under-point ?bufnr 
                                         ?lineno
                                         1 
                                         (or ?by 1)))

(defn- demote-bullet-or-heading [?bufnr ?lineno ?by]
  (replace-heading-or-bullet-under-point ?bufnr 
                                         ?lineno
                                         -1 
                                         (or ?by 1)))

(defn- next-heading []
  (vim.cmd "/^\\*")
  (vim.cmd "noh"))

(defn- prev-heading []
  (vim.cmd "?^\\*")
  (vim.cmd "noh"))

(utils.define-keys [{:keys "<C-A-j>"
                     :key-attribs "buffer"
                     :events "BufEnter"
                     :patterns "*norg"
                     :exec ":normal! o_i* "}

                    {:keys "<C-j>"
                     :key-attribs ["buffer" "silent"]
                     :events "BufEnter"
                     :patterns "*norg"
                     :exec insert-bullet-or-heading}

                    {:keys "<C-f>"
                     :key-attribs ["buffer" "silent"]
                     :events "BufEnter"
                     :patterns "*norg"
                     :exec next-heading}

                    {:keys "<C-b>"
                     :key-attribs ["buffer" "silent"]
                     :events "BufEnter"
                     :patterns "*norg"
                     :exec prev-heading}

                    {:keys "<A-l>"
                     :key-attribs ["buffer" "silent"]
                     :events "BufEnter"
                     :patterns "*norg"
                     :exec promote-bullet-or-heading}

                    ; Demote bullet or point
                    {:keys "<A-h>"
                     :key-attribs ["buffer" "silent"]
                     :events "BufEnter"
                     :patterns "*norg"
                     :exec demote-bullet-or-heading}])
