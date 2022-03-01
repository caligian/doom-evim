(local Runner {})
(local utils (require :utils))
(local core (require :aniseed.core))
(local str (require :aniseed.string))
(local vimp (require :vimp))
(local valid-commands {})

(fn Runner.uppercase [s]
  (string.gsub s "^." string.upper))

(fn Runner.take-runner-input [binary]
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

        final-cmd (string.format "%s %s %s %s %s &>/dev/stdout" pipe-args binary binary-args file extra-args)]
    (values final-cmd file)))

(fn Runner._runner [binary ?hook]
  (let [(cmd file) (Runner.take-runner-input binary)]
    (if (and ?hook file)
      (utils.async-sh cmd #(?hook file $1))
      (utils.async-sh cmd :sp))))

(fn Runner.make-runner [ft of]
  (let [binary (?. doom.langs ft of)
        cmd-name (.. "Runner" (Runner.uppercase of) (Runner.uppercase ft))]
      (when binary 
        (tset valid-commands cmd-name true)
        (vimp.map_command cmd-name #(Runner._runner binary)))))

(fn Runner.current-buffer-runner [op]
  (let [ft vim.bo.filetype
        sample-cmd (.. :Runner (Runner.uppercase op) (Runner.uppercase ft))
        is-valid-op (. valid-commands sample-cmd)]
    (when is-valid-op
      (vim.cmd (.. ":" sample-cmd))
      true)))

(fn Runner.setup []
  (each [_ lang (ipairs (utils.keys doom.langs))]
    (each [_ op (ipairs [:build :test :compile])]
      (Runner.make-runner lang op)))

  (utils.define-keys [{:keys "<leader>mC" :exec ":RunnerCompile" :help "Compile <lang>"}
                      {:keys "<leader>mB" :exec ":RunnerBuild" :help "Build <lang>"}
                      {:keys "<leader>mT" :exec ":RunnerTest" :help "Test <lang>"}

                      {:keys "<leader>mc" :exec #(Runner.current-buffer-runner :compile) :help "Format buffer file"}
                      {:keys "<leader>mb" :exec #(Runner.current-buffer-runner :build) :help "Build buffer file"}
                      {:keys "<leader>mt" :exec #(Runner.current-buffer-runner :test) :help "Compile buffer file"}]))

Runner
