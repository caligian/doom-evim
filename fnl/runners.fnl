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

(defn- take-runner-input [binary]
  (let [_pipe-args (str.trim (vim.call :input "Pipe args > "))
        _binary-args (str.trim (vim.call :input (string.format "Args for %s > " binary)))
        _file (str.trim (vim.call :input "Use current file (n/y) > "))

        pipe-args (match _pipe-args
                    "" ""
                    _ (.. _pipe-args " | "))
        binary-args (match _binary-args
                      "" ""
                      _ _binary-args)
        file (match _file
               "" (vim.fn.expand "%:p")
               :n ""
               :y (vim.fn.expand "%:p")
               _ _file)

        _extra-args (if (~= "" file) 
                      (str.trim (vim.call :input (string.format "Args for %s > " file)))
                      "")
        extra-args (if (~= "" _extra-args) 
                     (match _extra-args
                       "" ""
                       _ _extra-args)
                     "")

        final-cmd (string.format "%s %s %s %s %s" pipe-args binary binary-args file extra-args)]
    final-cmd))

(defn- _runner [binary]
  (let [cmd (take-runner-input binary)]
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
