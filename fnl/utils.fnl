(local Utils {})
(local core (require :aniseed.core))
(local fs (require :path.fs))
(local logger (require :logger))
(local path (require :path))
(local str (require :aniseed.string))
(local fnl (require :fennel))
(local fun (require :fun))
(local rx (require :rex_pcre2))
(local wk (require :which-key))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; locals
(when (not _G.doom)
  (set _G.doom {}))

(when (not _G.doom.lambdas)
  (set _G.doom.lambdas {}))

(when (not _G.doom.map-help-groups)
  (set _G.doom.map-help-groups {:leader {} :localleader {}}))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(fn Utils.fmt [...]
  (string.format ...))

(fn Utils.path-exists [p]
  (path.exists p))

(fn Utils.list-dir [p]
  (when (path.exists p)
    (icollect [f _ (fs.dir p)] f)))

(fn Utils.register [f ?keybinding]
  (table.insert doom.lambdas f)
  (if (not ?keybinding)
    (Utils.fmt "lua f = doom.lambdas[%d]; f()" (length doom.lambdas))
    (Utils.fmt ":lua f = doom.lambdas[%d]; f()<CR>" (length doom.lambdas))))

(fn Utils.set-items [s]
  (icollect [k _ (pairs s.items)] k))

(fn Utils.keys [t]
  (icollect [k _ (pairs t)] k))

(fn Utils.vals [t]
  (icollect [_ v (pairs t)] v))

; Returns multiple: new array && popped element
(fn Utils.pop [ls]
  (let [l (length ls)
        arr (core.map #(. ls $1)
                      (Utils.vec (fun.take (- l 1) (fun.range l))))
        popped (. ls l)]
    (values arr popped)))

(fn Utils.dump [e]
  (print (vim.inspect e)))

(fn Utils.listify [?e ?force]
  (let [?force (or ?force false)]
    (if
      (not ?e)
      nil

      (not (= (type ?e) "table"))
      [?e]

      (and (= (type ?e) "table") ?force)
      [?e]

      ?e)))

(fn Utils.exec [cmd ...]
  (vim.cmd (Utils.fmt cmd ...)))

; Form: {:os func ...}
; First matching os will eval the function
(fn Utils.consider-os [os-funcs]
  (let [current-os (Utils.vec (fun.take 1 (fun.filter #(~= 0 (vim.fn.has $1)) (Utils.keys os-funcs))))]
    (. os-funcs (. current-os 1))))

(fn Utils.split-and [cmd direction string-only]
  (let [cmd (Utils.fmt ":%s | :%s" (or direction "sp") cmd)]
    (if string-only
      cmd
      (vim.cmd cmd))))

(fn Utils.split-term-and [cmd direction string-only]
  (let [cmd (Utils.fmt ":%s term://%s" (or direction "sp") cmd)]
    (if string-only
      cmd
      (vim.cmd cmd))))

(fn Utils.split-termdebug [debugger ?args debugee ?direction ?string]
  (let [args (or ?args "")
        direction (or ?direction "sp")
        cmd (Utils.fmt ":%s term://%s %s %s" direction debugger args debugee)]
    (if ?string
      cmd
      (vim.cmd cmd))))

(fn Utils.split-termdebug-buffer [debugger ?args ?direction ?string ?keybinding]
  (let [args (or ?args "")
        direction (match ?direction :sp "sp" :vsp "vsp" :tab "tabnew" nil "sp")
        cmd (Utils.fmt ":execute(\":%s term://%s %s \" . bufname(\"%%\"))" direction debugger args)
        final-cmd (if ?keybinding
                    (.. cmd "<CR>")
                    cmd)]
    (if
      ?keybinding
      final-cmd

      (if ?string
        cmd
        (vim.cmd cmd)))))

(fn Utils.vec [gen]
  (let [t {}]
    (fun.each (fn [...]
                (let [args [...]]
                  (if (= (length args) 1)
                    (table.insert t (. args 1))
                    (table.insert t args))))
              gen)
    t))

(fn Utils.rest [v]
  (icollect [_ i (fun.tail v)] i))

(fn Utils.first [v]
  (. v 1))

(fn Utils.ifirst [gen]
  (fun.head gen))

(fn Utils.irest [gen]
  (fun.tail gen))

(fn Utils.find [t key]
  (let [k (Utils.keys t)
        r (Utils.vec (fun.range 1 (length t)))
        found (core.filter #(rx.match (. k $1) key) r)]
    found))

; Only returns true or false
(fn Utils.grep [s pattern]
  (rx.match s pattern))

(fn Utils.split [s sep]
  (let [sep (or sep "[^\n\r]+")]
    (icollect [m (rx.split s sep)] m)))

(fn Utils.vec [iter]
  (let [t []]
    (fun.each (fn [e] (table.insert t e)) iter)
    t))

(fn Utils.join_path [...]
  (table.concat [...] "/"))

(fn Utils.datap [...]
  (let [data-path (vim.fn.stdpath "data")]
    (Utils.join_path data-path ...)))

(fn Utils.confp [...]
  (let [conf-path (vim.fn.stdpath "config")]
    (Utils.join_path conf-path ...)))

;; sed
;; Works like GNU sed and supports pcre2 regex
(fn Utils.sed [s replacement-a substitute-a]
  (if
    (not (= (length replacement-a) 0))
    (let [replacement-a (Utils.listify replacement-a)
          substitute-a (Utils.listify substitute-a)
          first-r (fun.head replacement-a)
          first-s (fun.head substitute-a)
          rest-r  (icollect [i (fun.tail replacement-a)] i)
          rest-s  (icollect [i (fun.tail substitute-a)] i)]
      (Utils.sed
        (rx.gsub s first-r first-s)
        rest-r
        rest-s))
    s))

; Traverses through r-a and tries to match regex to s
; If match is true then return the sed string
(fn Utils.match-sed [s r-a s-a]
  (if (= (length r-a) 0)
    s
    (let [current-regex (Utils.first r-a)
          rest-regex (Utils.rest r-a)

          current-sub (Utils.first s-a)
          rest-sub (Utils.rest s-a)

          does-match (rx.match s current-regex)]
      (if does-match
        (Utils.match-sed (rx.gsub s current-regex current-sub)
                   []
                   [])
        (Utils.match-sed s
                   rest-regex
                   rest-sub)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; buffer and window related functions
(fn Utils.linenum [?bufnr]
  (. (vim.api.nvim_win_get_cursor (or ?bufnr 0)) 1))

; Tuple is (row col)
; Row is 1 indexed and columns are 0 indexed
(fn Utils.pos [?bufnr]
  (vim.api.nvim_win_get_cursor (or ?bufnr 0)))


(fn Utils.current-line [?bufnr]
  (table.concat (vim.api.nvim_buf_get_lines (or ?bufnr 0)
                                            (- (Utils.linenum) 1)
                                            (Utils.linenum)
                                            false) ""))

(fn Utils.set-pos [?bufnr [row ?column]]
  (vim.api.nvim_win_set_cursor (or ?bufnr 0)
                               [row (or ?column 1)]))

(fn Utils.vpos [?bufnr]
  [(vim.fn.line "'<")
   (vim.fn.line "'>")])

(fn Utils.eval-at-line [?bufnr ?lineno cmd]
  (let [bufnr  (or ?bufnr  0)
        cmd (if (= (type cmd) "string")
              cmd
              (Utils.register cmd))
        lineno (or ?lineno (Utils.linenum))]
    (Utils.set-pos bufnr [lineno])
    (vim.cmd cmd)))

(fn Utils.eval-times [cmd ?lineno]
  (let [start (or ?lineno (+ 1 (Utils.linenum)))
        count vim.v.count
        end   (+ count start)]
    (if ?lineno
      (for [i start end 1]
        (Utils.eval-at-line 0 i cmd))
      (for [i start end 1]
        (vim.cmd cmd)))))

; s can be a string or a list of strings
(fn Utils.set-text [?bufnr [start-row start-column] [end-row end-column] s]
  (let [bufnr (or ?bufnr 0)
        s     (Utils.listify s)]
    (vim.api.nvim_buf_set_text bufnr
                               start-row
                               start-column
                               end-row
                               end-column
                               s)))

(fn Utils.set-lines [?bufnr [start-row ?end-row] s]
  (let [s (if (= (type s) "string")
            (Utils.split s "[\n\r]+")
            (Utils.listify s))
        end-row (or ?end-row (length s))
        bufnr (or ?bufnr 0)]
    (vim.api.nvim_buf_set_lines bufnr start-row end-row false s)))

(fn Utils.get-line-count [?bufnr]
  (vim.api.nvim_buf_line_count (or ?bufnr 0)))

(fn Utils.buf-loaded? [?bufnr]
  (vim.api.nvim_buf_is_loaded (or ?bufnr 0)))

(fn Utils.get-buf-var [?bufnr varname]
  (vim.api.nvim_buf_get_var (or ?bufnr 0) varname))

(fn Utils.get-buf-opt [?bufnr opt]
  (vim.api.nvim_buf_get_option (or ?bufnr 0) opt))

(fn Utils.get-buf-name [?bufnr]
  (vim.api.nvim_buf_get_name (or ?bufnr 0)))

(fn Utils.get-bufnr [?bufname]
  (let [bufnr (vim.call "bufnr" (or ?bufname "%"))]
    (if (= bufnr -1) false bufnr)))

(fn Utils.buffer-string [?bufnr [start-row ?end-row] ?concat]
  (let [end-row (or ?end-row (+ 1 start-row))
        bufnr   (or ?bufnr 0)
        concat  (fn [s] (if ?concat (table.concat s "\n") s))
        lines (vim.api.nvim_buf_get_lines bufnr start-row end-row false)]
    (concat lines)))

; Just like emacs' save-excursion except that this is not a macro
; Executes a function and then returns the cursor to its original position
(fn Utils.save-excursion [f]
  (let [current-bufnr (Utils.get-bufnr :%)
        output        (f)]
    (vim.cmd (.. ":buffer " current-bufnr)) 
    output))

; Get text in visual range
(fn Utils.vtext [?concat]
  (let [concat (fn [s] (if ?concat (table.concat s "\n") s))
        (bufnr start-line start-column) (unpack (vim.call "getpos" "'<"))
        (_ end-line end-column) (unpack (vim.call "getpos" "'>"))
        lines (Utils.buffer-string 0 [(- start-line 1) end-line] false)
        first-line (. lines 1)
        last-line  (. lines (length lines))]
    (if (= (length lines) 1)
      (concat (string.sub first-line start-column end-column))
      (do
        (tset lines 1 (string.sub first-line start-column (length first-line)))
        (tset lines (length lines) (string.sub last-line 1 end-column))
        (concat lines)))))

; Work on a range of lines. However, ignore the text that lies within that range
(fn Utils.line-range-exec [cmd]
  (let [[start end] (Utils.vpos)
        cmd (if
              (= "string" (type cmd))
              cmd

              (= "function" (type cmd))
              (Utils.register cmd))]

    (when (and (> start 0)
               (> end 0))
      (for [i start end]
        (Utils.exec "normal! %dG$" i)
        (vim.cmd cmd)))))

; if newline is true then count will be assumed to be on each new line
(fn Utils.respect-count [cmd ?newline ?keybinding]
  (lambda -respect-count []
    (let [count (if (= vim.v.count 0)
                  1
                  vim.v.count)
          current-line (Utils.linenum)
          cmd (if
                (= (type cmd) "string")
                cmd

                (= (type cmd) "function")
                (Utils.register cmd))
          last-line (+ current-line vim.v.count)
          newline (or ?newline false)]
      (if newline
        (for [i current-line last-line 1]
              (Utils.exec "normal! %dG" i)
              (vim.cmd cmd))

        (for [i 1 count]
          (vim.cmd cmd)))))
  (Utils.register -respect-count (or ?keybinding false)))

(fn Utils.get-line [?bufnr ?lineno]
  (let [bufnr (or ?bufnr 0)
        lineno (or ?lineno (Utils.lineno))
        s (Utils.buffer-string bufnr [lineno (+ 1 lineno)] true)]
    (if (= (length s) 0)
      ""
      s)))

(fn Utils.to-temp-buffer [s ?direction]
  (let [direction (or ?direction "sp")
        s (Utils.listify s)
        s-len (length s)
        buffer-name "_temp_output_buffer"
        buf-exists (vim.fn.bufnr buffer-name)
        bufnr (if (= buf-exists -1)
                (do
                  (vim.fn.bufadd buffer-name)
                  (set vim.bo.buftype :nofile)
                  (vim.fn.bufnr buffer-name))
                (vim.fn.bufnr buffer-name))
        number-of-lines (Utils.get-line-count bufnr)]
    (Utils.set-lines bufnr [0 number-of-lines] "")
    (Utils.set-lines bufnr [0 (- s-len 1)] s)
    (vim.cmd (Utils.fmt ":%s | b %s" direction buffer-name))))

(fn Utils.sh [s ?buf]
  (lambda get-output [s]
    (core.spit ".temp.sh" s)
    (str.trim (vim.call "system" "bash .temp.sh")))

  (lambda show-in-buffer [s]
    (Utils.to-temp-buffer s :sp))

  (let [out (get-output s)]
    (vim.call :system "rm .temp.sh")

    (if ?buf
      (Utils.show-in-buffer out)
      out)))

; Run an async command in shell and split
(fn Utils.async-sh [s ?d]
  (let [f (lambda __process [id data event]
            (if (= (type ?d) "function")
              (?d data)
              (Utils.to-temp-buffer data (or ?d "sp"))))]
    (vim.fn.jobstart s
                     {:on_stdout f
                      :stdout_buffered true})))

(fn Utils.adjust-indent [?towards ?lineno]
  (lambda -indent [towards lineno]
    (let [lineno (- lineno 1)
          line (Utils.get-line 0 lineno)]
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
              num-whitespace (if (> vim.v.count 0)
                               (* num-whitespace vim.v.count)
                               num-whitespace)
              modified-line (when first-whitespace
                              (if (= towards 1)
                                (string.gsub current-line-s "^" (string.rep " " vim.bo.shiftwidth))
                                (string.gsub current-line-s (.. "^" (string.rep " " num-whitespace)) "")))]
          (Utils.set-lines 0 [current-line-num (+ current-line-num 1)] modified-line)))))
    (-indent (or ?towards 1) (or ?lineno (Utils.linenum))))

(fn Utils.increase-indent [?lineno]
  (Utils.adjust-indent 1 ?lineno))

(fn Utils.decrease-indent [?lineno]
  (Utils.adjust-indent -1 ?lineno))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; autocmd and augroup functions

;; autocmd-str
;; Get an autocmd string that can be executed with vim.cmd
(fn Utils.autocmd-str [group event pattern exec]
  (let [exec (if (= (type exec) "string")
               exec
               (Utils.register exec))]
    (string.format "autocmd %s %s %s %s" group event pattern exec)))

(fn Utils.autocmd [...]
  (vim.cmd (Utils.autocmd-str ...)))

(fn Utils.augroup [name ?autocmd-forms]
  "Make an augroup using autocmd forms"
  (vim.cmd (Utils.fmt "augroup %s\n    autocmd!\n augroup END" name))
  (when ?autocmd-forms
    (each [_ form (ipairs ?autocmd-forms)]
          (Utils.autocmd name (unpack ?autocmd-forms)))))

(fn Utils.add-hook [ ?groups ?events ?patterns exec ]
  (let [_events (or (Utils.listify ?events) ["BufEnter"])
       _patterns (or (Utils.listify ?patterns) ["*"])
       _groups (or (Utils.listify ?groups) ["GlobalHook"])
       exec (if (= (type exec) "function")
              (Utils.register exec)
              exec)]

    (assert (= (length _events) (length _patterns)))

    (each [_ g (ipairs _groups)]
      (for [i 1 (length _events)]
        (vim.cmd (Utils.autocmd-str g
                              (. _events i)
                              (. _patterns i)
                              exec))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Keybinding-related functions
(fn Utils.get-help-desc [ll l first-key help-desc]
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

(fn Utils.register-to-wk [keys help ?help-desc ?not-register]
  (when (Utils.grep keys "leader")
    (let [ll-prefix (Utils.grep keys "<localleader")
          l-prefix  (Utils.grep keys "<leader")
          keys (Utils.sed keys ["([<>]|localleader|leader)"] [""])
          first-key (rx.match keys "^.")
          help-desc (Utils.get-help-desc ll-prefix first-key (or ?help-desc false))
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
        (if ?not-register
          original-t
          (wk.register original-t {:prefix "<localleader>"}))

        l-prefix
        (if ?not-register
          original-t
          (wk.register original-t {:prefix "<leader>"}))))))

(fn Utils.define-key [opts]
  (let [noremap (match opts.noremap
                  false false
                  _ true)
        key-attribs (or (Utils.listify opts.key-attribs) ["silent"])
        keys opts.keys
        modes (or (Utils.listify opts.modes) ["n"])
        events (or (Utils.listify opts.events)
                   (if opts.patterns "BufEnter" false))
        patterns (or (Utils.listify opts.patterns) false)
        exec (if (= (type opts.exec) "function")
               (Utils.register opts.exec true)
               opts.exec)
        help (or opts.help exec)
        help-group (or opts.help-group "")
        repeatable (or opts.repeatable false)
        groups (or (Utils.listify opts.groups) false)

        ; Not a part of opts
        has-ll (if (Utils.grep keys "localleader")
                 {:prefix "<localleader>"}
                 false)
        has-l (if (Utils.grep keys "<leader>")
                {:prefix "<leader>"}
                false)

        key-attribs-str (table.concat (Utils.vec (fun.map (fn [s] (string.format "<%s>" s)) key-attribs)) " ")
        key-command-str (string.format "%s %s %s %s" (if noremap "noremap" "map") key-attribs-str keys exec)
        key-command-strings (core.map (fn [s]
                                        (if opts.repeatable
                                          (string.format ":Repeatable %s%s" s key-command-str)
                                          (string.format ":%s%s" s key-command-str)))
                                      modes)]

    (if (and events
             patterns)
      (fun.each #(Utils.add-hook groups events patterns $1) key-command-strings)
      (fun.each vim.cmd key-command-strings))

    (Utils.register-to-wk keys help help-group)))

(fn Utils.define-keys [opts-a]
  (each [_ a (ipairs opts-a)]
    (Utils.define-key a)))

; Convert fnl to lua
(fn Utils.convert-to-lua [?filenames]
  (let [filenames (or ?filenames doom.user_compile_fnl)
        compiled-user-lua-path (Utils.join_path (os.getenv "HOME") ".vdoom.d" "compiled")
        fnl-user-configs-path (Utils.join_path (os.getenv "HOME") ".vdoom.d" "fnl")
        filenames (Utils.listify filenames)
        src-filenames (core.map #(Utils.join_path fnl-user-configs-path (.. $1 ".fnl")) filenames)
        dest-filenames (core.map #(Utils.join_path compiled-user-lua-path (.. "user-fnl-" $1 ".lua")) filenames)
        zipped-paths (fun.zip src-filenames dest-filenames)]
    (fun.each
      (fn [src dest]
        (when (Utils.path-exists src)
          (let [s (core.slurp src)
                compiled (fnl.compileString s)]
            (core.spit dest compiled))))
      zipped-paths)))

; For error handling
(fn Utils.try-then-else [try-f success-f failure-f]
  (let [(status message) (pcall try-f)]
    (if status
      (success-f)
      (failure-f message))))

(fn Utils.try-catch-then [try-f handle-f ?then-f]
  (let [(status message) (xpcall try-f handle-f)]
    (when ?then-f (?then-f))))

(fn Utils.try-require [module-name type-module ?exec ?defer]
  (if ?defer
    (vim.defer_fn #(Utils.try-then-else
                     (fn []
                       (let [m (require module-name)]
                         (when ?exec
                           (?exec m))))
                     #(logger.ilog (Utils.fmt "[%s] Module: %s OK" type-module module-name))
                     #(logger.flog (Utils.fmt "[%s] Module: %s DEBUG-REQUIRED\n%s" type-module module-name $1)))
                  ?defer)
    (Utils.try-then-else
      #(require module-name)
      #(logger.ilog (Utils.fmt "[%s] Module: %s OK" type-module module-name))
      #(logger.flog (Utils.fmt "[%s] Module: %s DEBUG-REQUIRED\n%s" type-module module-name $1)))))

; Increases the size of current font by 1
(fn Utils.adjust-font-size [inc-or-dec]
  (let [(font size) (string.match vim.go.guifont "([^:]+):h([^$]+)")
        new (if (= inc-or-dec "+")
              (+ size 2)
              (- size 2))
        new-font (.. font ":h" new)]
    (set vim.go.guifont new-font)))

; Get user input
(fn Utils.get-user-input [prompt validate loop ?opts]
  (let [use-validate-r (or (?. ?opts :use_function) false)
        _first-input (vim.call :input prompt)
        _first-input (str.trim _first-input)]
    (if (= _first-input "")
      (Utils.get-user-input prompt validate loop)
      (let [is-valid (validate _first-input)]
        (if is-valid
          (if use-validate-r
            is-valid
            _first-input)
          (if loop
            (Utils.get-user-input prompt validate true)))))))

(fn Utils.get-user-inputs [...]
  (let [args [...]]
    (each [_ i (ipairs args)]
      (Utils.get-user-input (unpack i)))))

(fn Utils.set-theme [?theme-name]
  (if doom.theme
    (vim.cmd (.. "color " doom.theme))
    (vim.cmd (Utils.fmt "color %s" (or ?theme-name :night-owl))))

  (let [modeline (require :modeline)]
    (modeline.setup_colors)))

; Has no real use as of now.
(lambda Utils.auto-compile-lua []
  ; Add a hook here
  (Utils.add-hook :GlobalHook :BufWritePost "*fnl" (fn []
                                                     (let [filename (vim.fn.expand "%:p")
                                                           basename (path.name filename)
                                                           ws (path.parent filename)
                                                           s (core.slurp filename)
                                                           compiled (fnl.compileString s)
                                                           dest-filename (Utils.sed filename "fnl$" "lua")
                                                           dest (if
                                                                  (Utils.grep filename "vdoom")
                                                                  (Utils.fmt "%s/.vdoom.d/compiled/%s" (os.getenv "HOME") basename)

                                                                  (Utils.grep filename ".config/nvim")
                                                                  (Utils.confp "compiled" basename)

                                                                  dest-filename)]
                                                       (core.spit dest compiled)))))

; This function is best useful when used in tandem with other functions
; that work with the open buffer.
; However, if you don't use any other function after open a temp buffer
; and quit it, nothing happens and the buffer just closes.
(lambda Utils.open-temp-input-buffer [bufname ?direction ?ft]
  (let [current-ft (if
                     true
                     vim.bo.filetype

                     ?ft
                     ?ft

                     false)
        direction (or ?direction "sp")]

    (if (= direction "vsp")
      (vim.cmd (Utils.fmt ":vsplit %s" bufname))
      (vim.cmd (Utils.fmt ":split %s" bufname)))

    (set vim.bo.buftype "nofile")
    (set vim.bo.buflisted false)

    (when current-ft
      (set vim.bo.filetype current-ft))))


; callback function should accept one argument
; This argument is the string obtained from buffer defined by bufname
(fn Utils.get-temp-buffer-string-and-cb [bufname f]
  (let [s (Utils.buffer-string (vim.call :bufnr bufname) [0 -1] false)]
    (if (and (= 1 (length s))
             (= (. s 1) ""))
      false
      (f s))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Json utils
(lambda Utils.slurp-json [path ?cb]
  (let [s (vim.call :json_decode (core.slurp path))]
    (if ?cb
      (?cb s)
      s)))

; post-write-cb does not take any args
; pre-write-cb is called on the data before converting it to json
(lambda Utils.spit-json [path data ?pre-write-cb ?post-write-cb]
  (let [str (if ?pre-write-cb
              (?pre-write-cb data)
              data)
        json (vim.call :json_encode str)]
    (core.spit path json)

    (if ?post-write-cb
      (?post-write-cb)
      json)))

Utils
