(local Templates {})
(local Core (require :aniseed.core))
(local Fennel (require :fennel))
(local Utils (require :utils))
(local Path (require :path))
(local doom-templates-path (Utils.datap "templates"))

(set Templates.ft-ext-assoc (or doom.templates.ft-ext-assoc {:fennel "fnl"
                                                             :python "py"
                                                             :ruby "rb"
                                                             :perl "pl"}))
(set Templates.extensions (or doom.templates.extensions [:fnl]))

; Format is <filetype>.lua
; The luafile should contain a table containing this format
; <pattern to match> = <string to insert>

(lambda Templates.get-ext []
  (vim.fn.expand "%:e"))

(lambda Templates.get-template-path [ext]
  (Path doom-templates-path (.. ext ".lua")))

(lambda Templates.get-ext-templates [ext]
  (let [template-path (Templates.get-template-path ext)]
    (when (Path.exists template-path)
      (dofile template-path))))

(lambda Templates.merge-dict [t1 t2]
  (each [k v (pairs t2)]
    (tset t1 k v))
  t1)

(lambda Templates.save-new-template-table [ext t]
  (let [templates (or (Templates.get-ext-templates ext) {})
        merged (Templates.merge-dict templates t)
        p (Templates.get-template-path ext)]
    (Core.spit p (.. "return " (vim.inspect merged)))))

(lambda Templates.save-new-template [ext patterns str]
  (Templates.save-new-template-table ext {patterns str}))

(lambda Templates.insert-if-path-matches [ext]
  (let [template-d (Templates.get-ext-templates ext)]
    (when template-d
      (let [current-file (vim.fn.expand "%:p")
            matching-pat (Core.filter #(Utils.grep current-file $1) (Utils.keys template-d))]
        (when (> (length matching-pat) 0)
          (each [_ pat (ipairs matching-pat)]
            (let [s (. template-d pat)
                  s (Utils.split s "[\n\r]+")]
              (Utils.set-lines 0 [0 (length s)] s)))
          true)))))

(lambda Templates.make-template-au [ext]
  (Utils.autocmd :GlobalHook :BufNewFile (.. "*" ext) #(Templates.insert-if-path-matches ext)))

(lambda Templates.setup []
  (Core.map Templates.make-template-au Templates.extensions) 

  (Utils.define-keys [{:keys "<leader>&tv"
                       :help "Edit new template in vsplit"
                       :exec #(let [ft vim.bo.filetype
                                    bufname (.. "_new_template_" ft)]
                                (Utils.open-temp-input-buffer bufname :vsp ft))}
                      
                      {:keys "<leader>&ts"
                       :help "Edit new template in split"
                       :exec #(let [ft vim.bo.filetype
                                    bufname (.. "_new_template_" ft)]
                                (Utils.open-temp-input-buffer bufname :sp ft))}
                      
                      {:keys "gx"
                       :patterns "_new_template_*"
                       :events "BufEnter"
                       :help "Save template"
                       :exec (fn []
                               (let [ft vim.bo.filetype
                                     ext (?. Templates.ft-ext-assoc ft)
                                     ext (if (not ext)
                                           (Utils.get-user-input "Template for extension? > " #(~= 0 (length $1)) true)
                                           ext)
                                     pattern (Utils.get-user-input "Filename pattern to match before insertion > "
                                                                   #(~= (length $1) 0)
                                                                   true)]
                                 (Utils.get-temp-buffer-string-and-cb (vim.fn.expand "%") 
                                                                      #(Templates.save-new-template ext pattern (table.concat $1 "\n")))))}]))

Templates
