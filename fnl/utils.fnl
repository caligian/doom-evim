(module utils
  {require {core aniseed.core
            str aniseed.string
            fnl  fennel
            fun  fun
            rx   rex_pcre2
            Set  Set
            wk   which-key}})

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; locals
(when (not _G.doom)
  (set _G.doom {}))

(when (not _G.doom.lambdas)
  (set _G.doom.lambdas {}))

(when (not _G.doom.map-help-groups)
  (set _G.doom.map-help-groups {:leader {} :localleader {}}))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defn fmt [...] 
  (string.format ...))

(defn path-exists [path]
  (let [exists (vim.fn.glob path)]
    (if (= (length exists) 0)
      false
      exists)))

(defn list-dir [path]
  (let [path (path-exists path)]
    (if path
      (let [path-arr (split path "\n")]
        (if (= (length path-arr) 0)
          path
          path-arr))
      false)))

(defn register [f ?keybinding]
  (table.insert doom.lambdas f)
  (if (not ?keybinding)
    (fmt "lua f = doom.lambdas[%d]; f()" (length doom.lambdas))
    (fmt ":lua f = doom.lambdas[%d]; f()<CR>" (length doom.lambdas))))

(defn set-items [s]
  (icollect [k _ (pairs s.items)] k))

(defn keys [t]
  (icollect [k _ (pairs t)] k))

(defn vals [t]
  (icollect [_ v (pairs t)] v))

(defn dump [e]
  (print (vim.inspect e)))

(defn listify [?e ?force]
  (let [?force (or ?force false)]
    (if 
      (not ?e)
      nil

      (not (= (type ?e) "table"))
      [?e]

      (and (= (type ?e) "table") ?force)
      [?e]

      ?e)))

(defn exec [cmd ...]
  (vim.cmd (fmt cmd ...)))





; Form: {:os func ...} 
; First matching os will eval the function
(defn consider-os [os-funcs]
  (let [current-os (vec (fun.take 1 (fun.filter #(~= 0 (vim.fn.has $1)) (keys os-funcs))))]
    (. os-funcs (. current-os 1))))

(defn split-and [cmd direction string-only]
  (let [cmd (fmt ":%s | :%s" (or direction "sp") cmd)]
    (if string-only 
      cmd
      (vim.cmd cmd))))

(defn split-term-and [cmd direction string-only]
  (let [cmd (fmt ":%s term://%s" (or direction "sp") cmd)]
    (if string-only 
      cmd
      (vim.cmd cmd))))

(defn split-termdebug [debugger ?args debugee ?direction ?string]
  (let [args (or ?args "")
        direction (or ?direction "sp")
        cmd (fmt ":%s term://%s %s %s" direction debugger args debugee)]
    (if ?string
      cmd
      (vim.cmd cmd))))

(defn split-termdebug-buffer [debugger ?args ?direction ?string ?keybinding]
  (let [args (or ?args "")
        direction (match ?direction :sp "sp" :vsp "vsp" :tab "tabnew" nil "sp")
        cmd (fmt ":execute(\":%s term://%s %s \" . bufname(\"%%\"))" direction debugger args)
        final-cmd (if ?keybinding
                    (.. cmd "<CR>")
                    cmd)]
    (if 
      ?keybinding
      final-cmd
      
      (if ?string
        cmd
        (vim.cmd cmd)))))

(defn vec [gen]
  (let [t {}]
    (fun.each (fn [...] 
                (let [args [...]]
                  (if (= (length args) 1)
                    (table.insert t (. args 1))
                    (table.insert t args)))) 
              gen)
    t))

(defn rest [v]
  (icollect [i (fun.tail v)] i))

(defn first [v]
  (. v 0))

(defn ifirst [gen]
  (fun.head gen))

(defn irest [gen]
  (fun.tail gen))

(defn find [t key]
  (let [k (keys t)
        r (vec (fun.range 1 (length t)))
        found (core.filter #(= (. k $1) key) r)]
    found))

; Only returns true or false
(defn grep [s pattern]
  (rx.match s pattern))

(defn split [s sep]
  (let [sep (or sep "[^\n\r]+")]
    (icollect [m (rx.split s sep)] m)))



(defn vec [iter]
  (let [t []]
    (fun.each (fn [e] (table.insert t e)) iter)
    t))

(defn join_path [...]
  (if 
    (= (vim.fn.has "win32") 1)
    (table.concat [...] "\\")
    
    (table.concat [...] "/")))

(defn datap [...]
  (let [data-path (vim.fn.stdpath "data")]
    (join_path data-path ...)))

(defn confp [...]
  (let [conf-path (vim.fn.stdpath "config")]
    (join_path conf-path ...)))

;; sed
;; Works like GNU sed and supports pcre2 regex
(defn sed [s replacement-a substitute-a]
  (if 
    (not (= (length replacement-a) 0))
    (let [first-r (fun.head replacement-a)
          first-s (fun.head substitute-a)
          rest-r  (icollect [i (fun.tail replacement-a)] i)
          rest-s  (icollect [i (fun.tail substitute-a)] i)]
      (sed 
        (rx.gsub s first-r first-s)
        rest-r
        rest-s))
    s))

(defn after! [pkg config-f]
  (let [packages (listify pkg)
        loaded   (vec (fun.filter #(. doom.packages $1) packages))
        equals   (= (length packages) (length loaded))]
    (if equals 
      (do (config-f) true)
      false)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; buffer and window related functions
(defn linenum [?bufnr]
  (. (vim.api.nvim_win_get_cursor (or ?bufnr 0)) 1))

; Tuple is (row col)
; Row is 1 indexed and columns are 0 indexed
(defn pos [?bufnr]
  (vim.api.nvim_win_get_cursor (or ?bufnr 0)))

(defn current-line [?bufnr]
  (table.concat (vim.api.nvim_buf_get_lines (or ?bufnr 0) 
                                            (- (linenum) 1) 
                                            (linenum) 
                                            false) ""))

(defn set-pos [?bufnr [row ?column]]
  (vim.api.nvim_win_set_cursor (or ?bufnr 0) 
                               [row (or ?column 1)]))

(defn vpos [?bufnr]
  [(vim.fn.line "'<") 
   (vim.fn.line "'>")])

(defn eval-at-line [?bufnr ?lineno cmd]
  (let [bufnr  (or ?bufnr  0)
        lineno (or ?lineno (linenum))]
    (set-pos bufnr [lineno])
    (vim.cmd cmd)))

(defn eval-times [cmd ?lineno]
  (let [start (or ?lineno (+ 1 (linenum)))
        count vim.v.count
        end   (+ count start)]
    (if ?lineno
      (for [i start end 1] 
        (eval-at-line 0 i cmd))
      (for [i start end 1]
        (vim.cmd cmd)))))

; s can be a string or a list of strings
(defn set-text [?bufnr [start-row start-column] [end-row end-column] s]
  (let [bufnr (or ?bufnr 0)
        s     (listify s)]
    (vim.api.nvim_buf_set_text bufnr 
                               start-row 
                               start-column
                               end-row
                               end-column
                               s)))

(defn set-lines [?bufnr [start-row ?end-row] s]
  (let [end-row (or ?end-row (+ 1 start-row))
        s (listify s)
        bufnr (or ?bufnr 0)]
    (vim.api.nvim_buf_set_lines bufnr start-row end-row false s)))

(defn get-line-count [?bufnr]
  (vim.api.nvim_buf_line_count (or ?bufnr 0)))

(defn buf-loaded? [?bufnr]
  (vim.api.nvim_buf_is_loaded (or ?bufnr 0)))

(defn get-buf-var [?bufnr varname]
  (vim.api.nvim_buf_get_var (or ?bufnr 0) varname))

(defn get-buf-opt [?bufnr opt]
  (vim.api.nvim_buf_get_option (or ?bufnr 0) opt))

(defn get-buf-name [?bufnr]
  (vim.api.nvim_buf_get_name (or ?bufnr 0)))

(defn get-bufnr [?bufname]
  (let [bufnr (vim.call "bufnr" (or ?bufname "%"))]
    (if (= bufnr -1) false bufnr)))

(defn buffer-string [?bufnr [start-row ?end-row] ?concat]
  (let [end-row (or ?end-row (+ 1 start-row))
        bufnr   (or ?bufnr 0)
        concat  (fn [s] (if ?concat (table.concat s "\n") s))
        lines (vim.api.nvim_buf_get_lines bufnr start-row end-row false)]
    (concat lines)))

; Just like emacs' save-excursion except that this is not a macro
; Executes a function and then returns the cursor to its original position
(defn save-excursion [?bufnr f]
  (let [original-pos (pos)
        output       (f)]
    (set-pos ?bufnr original-pos)
    output))

; Get text in visual range
(defn vtext [?concat]
  (let [concat (fn [s] (if ?concat (table.concat s "\n") s))
        (bufnr start-line start-column) (unpack (vim.call "getpos" "'<"))
        (_ end-line end-column) (unpack (vim.call "getpos" "'>"))
        lines (buffer-string 0 [(- start-line 1) end-line] false)
        first-line (. lines 1)
        last-line  (. lines (length lines))]
    (if (= (length lines) 1)
      (concat (string.sub first-line start-column end-column))
      (do 
        (tset lines 1 (string.sub first-line start-column (length first-line)))
        (tset lines (length lines) (string.sub last-line 1 end-column))
        (concat lines)))))

; Work on a range of lines. However, ignore the text that lies within that range
(defn line-range-exec [cmd]
  (let [[start end] (vpos)
       exec-each-line (fn [cmd start end] 
                        )
        cmd (if 
              (= "string" (type cmd))
              cmd
                    
              (= "function" (type cmd))
              (register cmd))]

    (when (and (> start 0)
               (> end 0))
      (for [i start end] 
        (exec "normal! %dG" i)
        (vim.cmd cmd))))) 

; if newline is true then count will be assumed to be on each new line
(defn respect-count [cmd ?newline ?keybinding]
  (defn -respect-count [] 
    (let [count (if (= (or vim.v.count 0) 0)
                  1
                  vim.v.count)
          current-line (linenum)
          cmd (if 
                (= (type cmd) "string")
                cmd 

                (= (type cmd) "function")
                (register cmd))
          last-line (+ current-line vim.v.count)
          newline (or ?newline false)]
      (for [i current-line last-line 1]
        (if newline 
          (do 
            (exec "normal! %dG" i) 
            (vim.cmd cmd))
          (vim.cmd cmd)))))
  (register -respect-count (or ?keybinding false)))

(defn -respect-count [cmd ?newline ?keybinding] 
    (let [count (if (= (or vim.v.count 0) 0)
                  1
                  vim.v.count)
          current-line (linenum)
          cmd (if 
                (= (type cmd) "string")
                cmd 

                (= (type cmd) "function")
                (register cmd))
          last-line (+ current-line vim.v.count)
          newline (or ?newline false)]
      (for [i current-line last-line 1]
        (if newline 
          (do 
            (print "line-num %d" i)
            (exec "normal! %dG" i) 
            (vim.cmd cmd))
          (vim.cmd cmd)))))

(defn get-line [?bufnr ?lineno]
  (let [bufnr (or ?bufnr 0)
        lineno (or ?lineno (linenum))
        s (buffer-string bufnr [lineno (+ 1 lineno)] true)]
    (if (= (length s) 0)
      false
      s)))


(defn to-temp-buffer [s ?direction]
  (let [direction (or ?direction "sp")
        s (listify s)
        s-len (length s)
        buffer-name "_temp_output_buffer"
        buf-exists (vim.fn.bufnr buffer-name)
        bufnr (if (= buf-exists -1)
                (do 
                  (vim.fn.bufadd buffer-name)
                  (vim.cmd (fmt "call setbufvar('%s', '%s', '%s')" buffer-name "&buftype" "nofile"))
                  (vim.fn.bufnr buffer-name))
                
                (vim.fn.bufnr buffer-name))
        number-of-lines (get-line-count bufnr)]
    (set-lines bufnr [0 number-of-lines] "")
    (set-lines bufnr [0 (- s-len 1)] s)
    (vim.cmd (fmt ":%s | b %s" direction buffer-name))))


(defn sh [s ?buf]
  (lambda get-output [s]
    (core.spit ".temp.sh" s)
    (str.trim (vim.call "system" "bash .temp.sh")))

  (lambda show-in-buffer [s]
    (to-temp-buffer s :sp))

  (if ?buf
    (show-in-buffer (get-output s))
    (get-output s)))


(defn adjust-indent [?towards ?lineno]
  (defn -indent [towards lineno]
    (let [lineno (- lineno 1)
          line (get-line 0 lineno)]
      (when line 
        (let [current-line-num lineno
              current-line-s line
              last-line (+ 1 current-line-num)
              (first-whitespace _) (string.find current-line-s "[^ \t]")
              first-whitespace (or first-whitespace 0)
              num-whitespace (if 
                               (> first-whitespace vim.bo.shiftwidth)
                               vim.bo.shiftwidth

                               (< first-whitespace vim.bo.shiftwidth)
                               (- first-whitespace 1)

                               vim.bo.shiftwidth)
              modified-line (when first-whitespace
                              (if (= towards 1)
                                (string.gsub current-line-s "^" (string.rep " " vim.bo.shiftwidth))
                                (string.gsub current-line-s (.. "^" (string.rep " " num-whitespace)) "")))]
          (set-lines 0 [current-line-num (+ current-line-num 1)] modified-line)))))
    (-indent (or ?towards 1) (or ?lineno (linenum))))

(defn increase-indent [?lineno]
  (adjust-indent 1 ?lineno))

(defn decrease-indent [?lineno]
  (adjust-indent -1 ?lineno))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; autocmd and augroup functions

;; autocmd-str
;; Get an autocmd string that can be executed with vim.cmd
(defn autocmd-str [group event pattern exec]
  (string.format "autocmd %s %s %s %s" group event pattern exec))

(defn autocmd [...]
  (vim.cmd (autocmd-str ...)))

(defn augroup [name ?autocmd-forms]
  "Make an augroup using autocmd forms"
  (vim.cmd (fmt "augroup %s\n    autocmd!\n augroup END" name))
  (when ?autocmd-forms
    (each [_ form (ipairs ?autocmd-forms)]
          (autocmd name (unpack ?autocmd-forms)))))

(defn add-hook [ ?groups ?events ?patterns exec ]
  (let [_events (or (listify ?events) ["BufEnter"]) 
       _patterns (or (listify ?patterns) ["*"]) 
       _groups (or (listify ?groups) ["GlobalHook"])
       exec (if (= (type exec) "function")
              (register exec)
              exec)]

    (assert (= (length _events) (length _patterns)))

    (each [_ g (ipairs _groups)]
      (for [i 1 (length _events)]
        (vim.cmd (autocmd-str g
                              (. _events i)
                              (. _patterns i)
                              exec))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Keybinding-related functions
(defn- get-help-desc [{:ll-prefix ll 
                        :l-prefix l
                        :first-key first-key
                        :help-desc help-desc}] 
  (when help-desc 
    (if ll
      (do 
        (tset doom.map-help-groups.localleader first-key help-desc)
        help-desc)
      (do 
        (tset doom.map-help-groups.localleader first-key help-desc)
        help-desc)))
  (if ll 
    (. doom.map-help-groups.localleader first-key)
    (. doom.map-help-groups.leader first-key)))

(defn register-to-wk [keys help ?help-desc]
  "Non-leader keys will be registered directly"

  (when (grep keys "leader") 
   (let [ll-prefix (grep keys "<localleader")
         l-prefix  (grep keys "<leader")
         keys (sed keys ["([<>]|localleader|leader)"] [""])
         first-key (rx.match keys "^.")
         help-desc (get-help-desc {:ll-prefix ll-prefix 
                                    :l-prefix l-prefix 
                                    :first-key first-key
                                    :help-desc (or ?help-desc false)})
         original-t (if help-desc
                      {first-key {:name help-desc}}
                      {first-key {}})
         help-t (fun.reduce 
                  (fn [t k] (tset t k {}) (. t k))
                  original-t 
                  (fun.iter keys))]

     (table.insert help-t help)

     (if 
       ll-prefix
       (wk.register original-t {:prefix "<localleader>"})
       
       l-prefix
       (wk.register original-t {:prefix "<leader>"}))
     
     original-t)))

(defn define-key [opts]
  (let [noremap (or opts.noremap true)
        key-attribs (or (listify opts.key-attribs) ["silent"])
        keys opts.keys
        modes (or (listify opts.modes) ["n"])
        events (or (listify opts.events) false)
        patterns (or (listify opts.patterns) false)
        exec (if (= (type opts.exec) "function")
               (register opts.exec true)
               opts.exec)
        help (or opts.help exec)
        help-group (or opts.help-group 
                       (rx.gsub opts.keys "<(?:local)?leader>(.)[^$]+" "%1"))
        repeatable (or opts.repeatable false)
        groups (or (listify opts.groups) false)
        
        ; Not a part of opts
        key-attribs-str (table.concat (vec (fun.map (fn [s] (string.format "<%s>" s)) key-attribs)) " ")
        key-command-str (string.format "%s %s %s %s" (if noremap "noremap" "map") key-attribs-str keys exec)
        key-command-strings (vec (fun.map (fn [s] 
                                            (if opts.repeatable
                                              (string.format ":Repeatable %s%s" s key-command-str)
                                              (string.format ":%s%s" s key-command-str))) 
                                          modes))]
    (if events
      (fun.each 
        (fn [e] (add-hook groups events patterns e))
        key-command-strings)
      (fun.each vim.cmd key-command-strings))
    (register-to-wk keys help help-group)))

(defn define-keys [opts-a]
  (each [_ a (ipairs opts-a)]
    (define-key a)))

; Convert fnl to lua
(defn convert-to-lua [filenames]
  (let [compiled-user-lua-path (join_path (os.getenv "HOME") ".vdoom.d" "compiled")
        fnl-user-configs-path (join_path (os.getenv "HOME") ".vdoom.d" "fnl")
        filenames (listify filenames)
        src-filenames (core.map #(join_path fnl-user-configs-path (.. $1 ".fnl")) filenames)
        dest-filenames (core.map #(join_path compiled-user-lua-path (.. "user-fnl-" $1 ".lua")) filenames)
        zipped-paths (fun.zip src-filenames dest-filenames)]
    (fun.each 
      (fn [src dest] 
        (let [s (core.slurp src)
              compiled (fnl.compileString s)]
          (core.spit dest compiled)))
      zipped-paths)))

; Ensure that these files exist. 
; Don't worry, they will be made by default
(defn compile-user-fnl-configs []
  (let [configs ["init"
                 "utils"
                 "keybindings"
                 "configs" 
                 "lsp-configs"]]
    (convert-to-lua configs)))

; For error handling
(defn try-then-else [try-f success-f failure-f]
  (let [(status message) (pcall try-f)]
    (if status 
      (do 
        (success-f)
        status)
      (failure-f message))))

(defn try-catch-then [try-f handle-f then-f]
  (let [(status message) (xpcall try-f handle-f)]
    (then-f)))

(defn try-require-else [module-name type-module]
  (try-then-else 
    #(require module-name)
    #(logger.ilog (fmt "[%s] Module: %s OK" type-module module-name)) 
    #(logger.flog (fmt "[%s] Module: %s DEBUG-REQUIRED\n%s" type-module module-name $1))))

; Register all help-groups in <leader>
(each [k group-name (pairs doom.map-help-groups.leader)]
  (wk.register {k {:name group-name}} {:prefix "<leader>"}))
 
(each [k group-name (pairs doom.map-help-groups.localleader)]
  (wk.register {k {:name group-name}} {:prefix "<localleader>"}))
