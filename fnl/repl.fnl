(module repl
  {autoload {utils utils
             core aniseed.core}})

(when (not doom.repl)
  (set doom.repl {
                  :ft {:sh "bash"
                       :ruby "ruby"
                       :perl "perl"
                       :fennel "fennel"
                       :python "python"
                       :lua "lua"
                       :powershell "powershell"
                       :ps1 "powershell"}
                  
                  ; form: {:cmd {:id terminal_job_id :buffer bufnr}}
                  :running_repls {}}))


(defn echo [msg]
  (vim.cmd (utils.fmt "echom \"[REPL]: %s\"" (utils.sed msg ["\""] ["\\\""]))))

(defn new [cmd]
  (let [cmd-t (vim.split cmd " ")
        is-running (or (. doom.repl.running_repls cmd) false)
        does-bufexists (if is-running 
                         (~= (vim.fn.bufnr (. is-running :buffer)) -1)
                         false)]
    (if 
      (and is-running does-bufexists)
      (do 
        (echo (utils.fmt "REPL for command: '%s' is already running." (. is-running :cmd)))
        (. is-running :buffer)) 

      (and is-running (not does-bufexists))
      (do 
        (tset doom.repl.running_repls cmd nil)
        (new cmd))

      (do 
        (vim.cmd "tabnew")
        (vim.call "termopen" cmd-t)
        (let [bufnr (utils.get-bufnr)
              id vim.b.terminal_job_id]
          (vim.cmd "hide")
          (tset doom.repl.running_repls cmd {:buffer bufnr :cmd cmd :id id})
          (echo (utils.fmt "REPL for command: '%s' has been launched" cmd))
          bufnr)))))

(defn buffer-new [?cmd]
  (let [ft vim.bo.filetype
        cmd (if 
              ?cmd
              ?cmd

              (. doom.repl.ft ft)
              (. doom.repl.ft ft)

              false)]
    (if cmd
      (new cmd)
      false)))

(defn split-with-repl [?direction ?cmd]
  (let [bufnr (buffer-new ?cmd)
        direction (or ?direction "sp")]
    (when bufnr
      (vim.cmd (.. direction " | buffer " bufnr)))))

(defn split [?cmd]
  (split-with-repl :sp ?cmd))

(defn vsplit [?cmd]
  (split-with-repl :vsp ?cmd))

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

; keys
(utils.define-keys [{:keys "<localleader>ts" 
                     :exec split-shell
                     :help "Split buffer and open shell"
                     :help-group "t"}

                    {:keys "<localleader>tv" 
                     :exec vsplit-shell
                     :help "Split buffer and open shell"
                     :help-group "t"}

                    {:keys "<localleader>,s" 
                     :exec split
                     :help "Vsplit buffer and open ft REPL"
                     :help-group "t"}

                    {:keys "<localleader>,v" 
                     :exec vsplit
                     :help "Split buffer and open ft REPL"
                     :help-group "t"}
                    
                    {:keys "<localleader>,k"
                     :exec shutdown
                     :help "Shutdown current ft REPL" }
                    
                    {:keys "<localleader>,K"
                     :exec shutdown-all
                     :help "Shutdown all REPLs"}
                    
                    {:keys "<localleader>tk"
                     :help "Shutdown bash shell"
                     :exec (fn [] (shutdown "bash"))}])
