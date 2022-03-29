(local org (require :neorg))
(local Wk (require :which-key))
(local Utils (require :utils))

(org.setup {:load {:core.keybinds {:config {:default_keybinds true
                                            :neorg_leader "<Leader>o"}}

                   :core.integrations.nvim-cmp {:config {}}

                   :core.norg.journal {:config {:workspace "journal"
                                                :strategy "flat"}}
                   :core.defaults {}

                   :core.norg.concealer {:config {}}

                   :core.presenter {:config {}}

                   :core.norg.qol.toc {:config {}}

                   :core.norg.manoeuvre {:config {}}

                   :core.norg.dirman {:config {:workspaces {:work "~/Work"
                                                            :journal "~/Personal/Journal"
                                                            :gtd "~/Personal/GetThingsDone"
                                                            :default_workspace "~/Personal/neorg"
                                                            :personal "~/Personal"
                                                            :diary "~/Personal/Diary"}}}}})

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Making up the lack of promotion/demotion functions & insertion functions

(lambda linenum0 [?bufnr]
  (- (Utils.linenum ?bufnr) 1))

; 0 indexed
(lambda get-bullet-or-heading-under-point [?lineno]
  (let [lineno (or ?lineno (linenum0))
        line (Utils.get-line 0 lineno)]
    (if line
      (let [(wt bullet bullet-type contains) (Utils.grep line "^( *)(-+|~+|>+)(>)? *([^$]*)?")
            (hwt heading hcontains) (Utils.grep line "^( *)(\\*+) *([^$]*)")]
        (if 
          bullet
          (let [single (string.match bullet "^.")
                task (or (Utils.grep contains "\\[[^]]*\\]") "")
                contains (Utils.sed contains " *\\[[^]]*\\] *" "")
                len (length bullet)
                d {:single single
                   :base bullet
                   :task task
                   :type (or bullet-type "")
                   :is "bullet"
                   :whitespace wt
                   :contains contains
                   :len len}] 
            d)

          heading
          {:is "heading"
           :base heading
           :whitespace hwt
           :len (length heading)
           :single (Utils.grep heading "\\*")
           :contains hcontains} 

          false)))))

(lambda edit-base-and-get-sym [?by opts]
  (let [by (or ?by 1)
        sym (get-bullet-or-heading-under-point)]
    (when sym
      (let [base-len sym.len
            new-len (if opts.inc
                      (+ base-len by)
                      (- base-len by))
            final-len (if (< new-len 1)
                        1
                        new-len)]
        (set sym.base (string.rep sym.single final-len))
        sym))))

(lambda edit-base [?by opts]
  (let [sym (edit-base-and-get-sym ?by opts)]
    (when sym

      ; No buffer switching here.
      (vim.cmd (Utils.fmt ":s/\\( *\\)[>~*-]\\{1,\\}/\\1%s/ | noh"  sym.base)))))

(lambda construct-bullet-or-heading [sym]
  (if (= sym.is :bullet)
    (.. sym.whitespace sym.base sym.type " " sym.task " " sym.contains)
    (.. sym.whitespace sym.base " " sym.contains)))

; If ?sym is provided then use that
(lambda insert-new-bullet-or-heading [?sym]
  (let [sym (or ?sym (get-bullet-or-heading-under-point))]
    (if sym
      (vim.api.nvim_put [(do 
                           (set sym.contains "") 
                           (construct-bullet-or-heading sym))] 
                        :l 
                        true 
                        true))))

; 0 indexed
(lambda --get-previous-heading-linenum-recurse [current-linenum]
  (if (= current-linenum -1)
    false
    (let [current-line (Utils.get-line 0 current-linenum)
          matches (Utils.grep current-line "^ *\\*{1,}")] 
      (if matches
        current-linenum
        (--get-previous-heading-linenum-recurse (- current-linenum 1))))))

; 0 indexed
(lambda --get-next-heading-linenum-recurse [current-linenum]
  (if (= current-linenum (Utils.get-line-count))
    false
    (let [current-line (Utils.get-line 0 current-linenum)
          matches (Utils.grep current-line "^ *\\*{1,}")] 
      (if matches
        current-linenum
        (--get-next-heading-linenum-recurse (+ current-linenum 1))))))

(lambda goto-linenum0 [linenum0]
  (vim.call :setpos :. [0 (+ linenum0 1) 1]))

(lambda goto-next-heading []
  (let [current-linenum0 (linenum0)
        next-heading-linenum0 (--get-next-heading-linenum-recurse current-linenum0)]
    (print next-heading-linenum0)
    (when next-heading-linenum0
      (goto-linenum0 next-heading-linenum0))))

(lambda goto-previous-heading []
  (let [current-linenum0 (linenum0)
        previous-heading-linenum0 (--get-previous-heading-linenum-recurse current-linenum0)]
    (when previous-heading-linenum0
      (goto-linenum0 previous-heading-linenum0))))

; 0 indexed
(lambda insert-new-heading []
  (let [current-linenum0 (linenum0)
        previous-linenum0 (--get-previous-heading-linenum-recurse current-linenum0)
        sym (when previous-linenum0
              (get-bullet-or-heading-under-point previous-linenum0))]
    (if sym
      (insert-new-bullet-or-heading sym))))

(Utils.define-keys [{:keys "<C-b>"
                     :events "BufEnter"
                     :patterns "*norg"
                     :exec goto-previous-heading}

                    {:keys "<C-f>"
                     :events "BufEnter"
                     :patterns "*norg"
                     :exec goto-next-heading}

                    {:keys "<C-j>"
                     :events "BufEnter"
                     :patterns "*norg"
                     :exec insert-new-bullet-or-heading}

                    {:keys "<C-return>"
                     :events "BufEnter"
                     :patterns "*norg"
                     :exec insert-new-heading}

                    {:keys "<C-=>"
                     :events "BufEnter"
                     :patterns "*norg"
                     :exec #(edit-base 1 {:inc true})}
                    
                    {:keys "<C-->"
                     :events "BufEnter"
                     :patterns "*norg"
                     :exec #(edit-base 1 {:dec true})}])
