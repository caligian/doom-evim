(module repl
  {autoload {utils utils
             core aniseed.core}})

(local vimp (require :vimp))

(defn- echo [msg]
  (vim.cmd (utils.fmt "echom \"[REPL]: %s\"" (utils.sed msg ["\""] ["\\\""]))))

(defn- new [cmd ?id]
  (let [cmd-t (vim.split cmd " ")
        is-running (or (. doom.repl.running_repls cmd) false)
        does-bufexists (if is-running 
                         (~= (vim.fn.bufnr (. is-running :buffer)) -1)
                         false)]
    (if 
      (and is-running does-bufexists)
      (if ?id 
        (. is-running :id)
        (. is-running :buffer)) 

      (and is-running (not does-bufexists))
      (do 
        (tset doom.repl.running_repls cmd nil)
        (new cmd))

      (do 
        (vim.cmd "tabnew")
        (vim.call "termopen" cmd-t)
        (set vim.bo.buflisted true)

        (let [bufnr (utils.get-bufnr)
              id vim.b.terminal_job_id]
          (vim.cmd "hide")

          (tset doom.repl.running_repls cmd {:buffer bufnr :cmd cmd :id id})

          (echo (utils.fmt "REPL for command: '%s' has been launched" cmd))

          (if ?id
            (. is-running :id)
            bufnr))))))

(defn- buffer-new [?cmd ?id]
  (let [ft vim.bo.filetype
        id (or ?id false)
        cmd (if 
              ?cmd
              ?cmd

              (. doom.repl.ft ft)
              (. doom.repl.ft ft)

              false)]
    
    (if cmd
      (new cmd id)
      false)))

(defn split-with-repl [?direction ?cmd]
  (let [bufnr (buffer-new ?cmd)
        direction (match ?direction 
                    :sp "sp"
                    :vsp "vsp"
                    :tab "tabnew"
                    nil :sp)]
    (when bufnr
      (vim.cmd (.. direction " | buffer " bufnr)))))

(defn split [?cmd]
  (split-with-repl :sp ?cmd))

(defn vsplit [?cmd]
  (split-with-repl :vsp ?cmd))

(defn tabnew [?cmd]
  (split-with-repl :tab ?cmd))

(defn shutdown [?cmd]
  (let [cmd (or ?cmd (. doom.repl.ft vim.bo.filetype) false)
        is-running (if cmd 
                     (. doom.repl.running_repls cmd)
                     false)
        cmd (if is-running (. is-running :cmd) false)
        job-id (if is-running (. is-running :id) false)]
    (when job-id 
      (do 
        (vim.call "chanclose" job-id)
        (tset doom.repl.running_repls cmd nil)
        (echo (utils.fmt "REPL for command: '%s' has been shutdown" cmd))))))

(defn shutdown-all []
  (let [all-jobs (core.map #(. $1 :id) (utils.vals doom.repl.running_repls))]
    (core.map #(vim.call :chanclose $1) all-jobs)
    (set doom.repl.running_repls {})
    (echo "All REPLs have been shutdown")))

(defn split-shell []
  (split-with-repl :sp "bash"))

(defn vsplit-shell []
  (split-with-repl :vsp "bash"))

(defn tabnew-shell []
  (split-with-repl :tab "bash"))

(defn- get-string [what]
  (match what
    :visual (utils.vtext true)
    :line (utils.current-line) 
    :till-point (utils.buffer-string 0 [0 (utils.linenum)] true) 
    :buffer (utils.buffer-string 0 [0 -1] true)
    nil (get-string :line)))

(defn- send [?cmd what]
  (let [is-option (match what
                    :line "line"
                    :visual "visual"
                    :till-point "till-point"
                    :buffer "buffer"
                    nil false)
        s (if is-option
            (.. (get-string what) "\n\r")
            (.. what "\n\r"))
        id (buffer-new ?cmd true)]
    (when id
      (vim.call "chansend" id s))))

; REPL stuff
(vimp.map_command :REPLNew #(buffer-new $1))
(vimp.map_command :REPLSend #(send $1 $2))
(vimp.map_command :REPLGetString #(get-string $1))
(vimp.map_command :REPLSplit #(split))
(vimp.map_command :REPLVsplit #(vsplit))
(vimp.map_command :REPLTab #(tabnew))

; Shell stuff
(vimp.map_command :REPLTabShell tabnew-shell)
(vimp.map_command :REPLVsplitShell split-shell)
(vimp.map_command :REPLSplitShell vsplit-shell)
(vimp.map_command :REPLShellSend #(send "bash" $1))

; keys
(utils.define-keys [{:keys "<localleader>,t"
                     :exec tabnew
                     :help "Open a ft REPL in a new tab"}

                    {:keys "<localleader>,T"
                     :exec tabnew-shell
                     :help "Open a new bash REPL in a new tab"}

                    {:keys "<localleader>mee"
                     :exec #(send nil :line)
                     :help "Send current line to ft REPL"}

                    {:keys "<localleader>me."
                     :exec #(send nil :till-point)
                     :help "Send strings till-point to ft REPL"}

                    {:keys "<localleader>meb"
                     :exec #(send nil :buffer)
                     :help "Send current line to ft REPL"}
                    
                    {:keys "<localleader>meE"
                     :exec #(send :bash :line)
                     :help "Send current line to bash REPL"}

                    {:keys "<localleader>me>"
                     :exec #(send :bash :till-point)
                     :help "Send strings till-point to bash REPL"}

                    {:keys "<localleader>meB"
                     :exec #(send :bash :buffer)
                     :help "Send current line to ft REPL"}

                    {:keys "<localleader>meE"
                     :modes "v"
                     :exec #(send :bash :visual)
                     :help "Send visual range to bash REPL"}

                    {:keys "<localleader>mee"
                     :modes "v"
                     :exec #(send nil :visual)
                     :help "Send visual range to ft REPL"}
                    
                    {:keys "<localleader>ts" 
                     :exec split-shell
                     :help "Split buffer and open shell"}

                    {:keys "<localleader>tv" 
                     :exec vsplit-shell
                     :help "Split buffer and open shell"}

                    {:keys "<localleader>,s" 
                     :exec split
                     :help "Split buffer and open ft REPL"}

                    {:keys "<localleader>,v" 
                     :exec vsplit
                     :help "Vsplit buffer and open ft REPL"}

                    {:keys "<localleader>,k"
                     :exec shutdown
                     :help "Shutdown current ft REPL"}
                    
                    {:keys "<localleader>,K"
                     :exec shutdown-all
                     :help "Shutdown all REPLs"}
                    
                    {:keys "<localleader>tk"
                     :help "Shutdown bash shell"
                     :exec #(shutdown "bash")}])

; Debugging addon
(defn get-debugger [?cmd]
  (if ?cmd
    ?cmd
    (?. doom.langs vim.bo.filetype :debug)))

(defn start-debugger [?cmd]
  (let [debugger (or ?cmd (get-debugger))]
    (when debugger
      (let [debugger (or ?cmd (.. debugger " " (vim.fn.expand "%:p")))]
        (buffer-new debugger)))))

(defn split-debugger [?cmd]
  (when (start-debugger ?cmd)
    (split (get-debugger ?cmd))))

(defn vsplit-debugger [?cmd]
  (when (start-debugger ?cmd) 
    (vsplit (get-debugger ?cmd))))

(defn send-to-debugger [what ?cmd]
  (let [debugger (get-debugger ?cmd)]
    (when (start-debugger ?cmd)
      (send debugger what)
      what)))

(defn kill-debugger [?cmd]
  (shutdown (or ?cmd (get-debugger))))

; Map to commands
(vimp.map_command "SplitDebugger" #(split-debugger $1))
(vimp.map_command "VsplitDebugger" #(vsplit-debugger $1))
(vimp.map_command "DebuggerSend" #(send-to-debugger $1))
(vimp.map_command "KillDebugger" #(kill-debugger $1))
(vimp.map_command "StartDebugger" #(start-debugger $1))
(vimp.map_command "GetDebugger" #(echo (get-debugger)))

(utils.define-keys [{:keys "<F5>"
                     :exec split-debugger
                     :help "Split and show current ft debugger"}

                    {:keys "<F6>"
                     :exec vsplit-debugger
                     :help "Vsplit and show current ft debugger"}

                    {:keys "<F7>"
                     :exec kill-debugger}

                    {:keys "<F10>"
                     :exec #(send-to-debugger :n)}

                    {:keys "<F11>"
                     :exec #(send-to-debugger :s)}

                    {:keys "<S-F11>"
                     :exec #(send-to-debugger :c)}

                    {:keys "<F12>"
                     :exec #(send-to-debugger :r)}

                    {:keys "<F9>"
                     :exec #(send-to-debugger :b)}])
