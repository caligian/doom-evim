(module runners
  {autoload {utils utils
             core aniseed.core
             str aniseed.string
             Job plenary.job
             vimp vimp}})

(local valid-commands {})

(defn- get-output-and-split [s]
  (vim.fn.jobstart s
                   {:on_stdout (fn [id data event]
                                 (if data
                                   (utils.to-temp-buffer data)))
                    :stdout_buffered true}))

(defn- uppercase [s]
  (string.gsub s "^." string.upper))

(defn- _runner [binary]
  (let [args (string.format "Args for %s > " binary) 
        args (vim.call :input args)
        use-current-file (vim.call :input "Use current file? > ")
        use-current-file (str.trim use-current-file)
        file (if (~= use-current-file "y")
                (if (or (= use-current-file "n")
                        (= use-current-file ""))
                  ""
                  use-current-file) 
                (vim.fn.expand "%:p"))
        cmd (string.format "%s %s %s" binary args file)]
    (get-output-and-split cmd)))

(defn- make-runner [ft of]
  (let [binary (?. doom.langs ft of)
        cmd-name (.. "Runner" (uppercase of) (uppercase ft))]
    (when binary 
      (tset valid-commands cmd-name true)
      (vimp.map_command cmd-name #(_runner binary)))))

(defn- current-buffer-runner [op]
  (let [ft vim.bo.filetype
        sample-cmd (.. :Runner (uppercase op) (uppercase ft))
        is-valid-op (. valid-commands sample-cmd)]
    (when is-valid-op
      (vim.cmd (.. ":" sample-cmd))
      true)))

(each [_ lang (ipairs (utils.keys doom.langs))]
  (each [_ op (ipairs [:build :test :compile])]
    (make-runner lang op)))

(utils.define-keys [{:keys "<leader>mC" :exec ":RunnerCompile" :help "Compile <lang>"}
                    {:keys "<leader>mB" :exec ":RunnerBuild" :help "Build <lang>"}
                    {:keys "<leader>mT" :exec ":RunnerTest" :help "Test <lang>"}
                    {:keys "<leader>mc" :exec #(current-buffer-runner :compile) :help "Compile buffer file"}
                    {:keys "<leader>mb" :exec #(current-buffer-runner :build) :help "Build buffer file"}
                    {:keys "<leader>mt" :exec #(current-buffer-runner :test) :help "Compile buffer file"}])
