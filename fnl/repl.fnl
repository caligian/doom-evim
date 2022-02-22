(local Repl {})
(local utils (require :utils))
(local core (require :aniseed.core))
(local vimp (require :vimp))
(set vimp.always_override true)

(fn Repl.echo [msg]
  (vim.cmd (utils.fmt "echom \"[REPL]: %s\"" (utils.sed msg ["\""] ["\\\""]))))

(fn Repl.new [cmd ?id]
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
        (Repl.new cmd))

      (do 
        (vim.cmd "tabnew")
        (vim.call "termopen" cmd-t)
        (set vim.bo.buflisted false)

        (let [bufnr (utils.get-bufnr)
              id vim.b.terminal_job_id]
          (vim.cmd "hide")

          (tset doom.repl.running_repls cmd {:buffer bufnr :cmd cmd :id id})

          (Repl.echo (utils.fmt "REPL for command: '%s' has been launched" cmd))

          (if ?id
            (. is-running :id)
            bufnr))))))

(fn Repl.buffer-new [?cmd ?id]
  (let [ft vim.bo.filetype
        id (or ?id false)
        cmd (if 
              ?cmd
              ?cmd

              (. doom.repl.ft ft)
              (. doom.repl.ft ft)

              false)]
    
    (if cmd
      (Repl.new cmd id)
      false)))

(fn Repl.split-with-repl [?direction ?cmd]
  (let [bufnr (Repl.buffer-new ?cmd)
        direction (match ?direction 
                    :sp "sp"
                    :vsp "vsp"
                    :tab "tabnew"
                    nil :sp)]
    (when bufnr
      (vim.cmd (.. direction " | buffer " bufnr)))))

(fn Repl.split [?cmd]
  (Repl.split-with-repl :sp ?cmd))

(fn Repl.vsplit [?cmd]
  (Repl.split-with-repl :vsp ?cmd))

(fn Repl.tabnew [?cmd]
  (Repl.split-with-repl :tab ?cmd))

(fn Repl.shutdown [?cmd]
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
        (Repl.echo (utils.fmt "REPL for command: '%s' has been shutdown" cmd))))))

(fn Repl.shutdown-all []
  (let [all-jobs (core.map #(. $1 :id) (utils.vals doom.repl.running_repls))]
    (core.map #(vim.call :chanclose $1) all-jobs)
    (set doom.repl.running_repls {})
    (Repl.echo "All REPLs have been shutdown")))

(fn Repl.split-shell []
  (Repl.split-with-repl :sp "bash"))

(fn Repl.vsplit-shell []
  (Repl.split-with-repl :vsp "bash"))

(fn Repl.tabnew-shell []
  (Repl.split-with-repl :tab "bash"))

(fn Repl.get-string [what]
  (match what
    :visual (utils.vtext true)
    :line (utils.current-line) 
    :till-point (utils.buffer-string 0 [0 (utils.linenum)] true) 
    :buffer (utils.buffer-string 0 [0 -1] true)
    nil (Repl.get-string :line)))

(fn Repl.send [?cmd what]
  (let [is-option (match what
                    :line "line"
                    :visual "visual"
                    :till-point "till-point"
                    :buffer "buffer"
                    nil false)
        s (if is-option
            (.. (Repl.get-string what) "\n\r")
            (.. what "\n\r"))
        id (Repl.buffer-new ?cmd true)]
    (when id
      (vim.call "chansend" id s))))

; Debugging addon
(fn Repl.get-debugger [?cmd]
  (if ?cmd
    (.. ?cmd " " (vim.fn.expand "%:p"))

    (if (?. doom.langs vim.bo.filetype :debug)
      (utils.fmt "%s %s" 
                 (?. doom.langs vim.bo.filetype :debug)
                 (vim.fn.expand "%:p")))))

(fn Repl.start-debugger [?cmd]
  (let [debugger (or ?cmd (Repl.get-debugger))]
    (when debugger
      (Repl.buffer-new debugger))))

(fn Repl.split-debugger [?cmd]
  (when (Repl.start-debugger ?cmd)
    (Repl.split (Repl.get-debugger ?cmd))))

(fn Repl.vsplit-debugger [?cmd]
  (when (Repl.start-debugger ?cmd) 
    (Repl.vsplit (Repl.get-debugger ?cmd))))

(fn Repl.send-to-debugger [what ?cmd]
  (let [debugger (Repl.get-debugger ?cmd)]
    (when (Repl.start-debugger ?cmd)
      (Repl.send debugger what)
      what)))

(fn Repl.kill-debugger [?cmd]
  (Repl.shutdown (or ?cmd (Repl.get-debugger))))

(fn Repl.setup []
  ; REPL stuff
  (vimp.map_command :REPLNew #(Repl.buffer-new $1))
  (vimp.map_command :REPLSend #(Repl.send $1 $2))
  (vimp.map_command :REPLSplit #(Repl.split $1))
  (vimp.map_command :REPLVsplit #(Repl.vsplit $1))
  (vimp.map_command :REPLTab #(Repl.tabnew $1))

  ; Shell stuff
  (vimp.map_command :REPLTabShell Repl.tabnew-shell)
  (vimp.map_command :REPLVsplitShell Repl.split-shell)
  (vimp.map_command :REPLSplitShell Repl.vsplit-shell)
  (vimp.map_command :REPLShellSend #(Repl.send "bash" $1))

  ; keys
  (utils.define-keys [{:keys "<localleader>,t"
                       :exec Repl.tabnew
                       :help "Open a ft REPL in a new tab"}

                      {:keys "<localleader>,T"
                       :exec Repl.tabnew-shell
                       :help "Open a new bash REPL in a new tab"}

                      {:keys "<localleader>,e"
                       :exec #(Repl.send nil :line)
                       :help "Send current line to ft REPL"}

                      {:keys "<localleader>,."
                       :exec #(Repl.send nil :till-point)
                       :help "Send strings till-point to ft REPL"}

                      {:keys "<localleader>,b"
                       :exec #(Repl.send nil :buffer)
                       :help "Send buffer to ft REPL"}

                      {:keys "<localleader>,E"
                       :exec #(Repl.send :bash :line)
                       :help "Send current line to bash REPL"}

                      {:keys "<localleader>,>"
                       :exec #(Repl.send :bash :till-point)
                       :help "Send strings till-point to bash REPL"}

                      {:keys "<localleader>,B"
                       :exec #(Repl.send :bash :buffer)
                       :help "Send buffer to bash REPL"}

                      {:keys "<localleader>,E"
                       :modes "v"
                       :exec #(Repl.send :bash :visual)
                       :help "Send visual range to bash REPL"}

                      {:keys "<localleader>,e"
                       :modes "v"
                       :exec #(Repl.send nil :visual)
                       :help "Send visual range to ft REPL"}

                      {:keys "<localleader>ts" 
                       :exec Repl.split-shell
                       :help "Split buffer and open shell"}

                      {:keys "<localleader>tv" 
                       :exec Repl.vsplit-shell
                       :help "Split buffer and open shell"}

                      {:keys "<localleader>,s" 
                       :exec Repl.split
                       :help "Split buffer and open ft REPL"}

                      {:keys "<localleader>,v" 
                       :exec Repl.vsplit
                       :help "Vsplit buffer and open ft REPL"}

                      {:keys "<localleader>,k"
                       :exec Repl.shutdown
                       :help "Shutdown current ft REPL"}

                      {:keys "<localleader>,K"
                       :exec Repl.shutdown-all
                       :help "Shutdown all REPLs"}

                      {:keys "<localleader>tk"
                       :help "Shutdown bash shell"
                       :exec #(Repl.shutdown "bash")}])


  (vimp.map_command "SplitDebugger" #(Repl.split-debugger))
  (vimp.map_command "VsplitDebugger" #(Repl.vsplit-debugger))
  (vimp.map_command "DebuggerSend" #(Repl.send-to-debugger))
  (vimp.map_command "KillDebugger" #(Repl.kill-debugger))
  (vimp.map_command "StartDebugger" #(Repl.start-debugger))
  (vimp.map_command "GetDebugger" #(Repl.echo (Repl.get-debugger))))

Repl
