(module runners
  {autoload {utils utils
             core aniseed.core
             str aniseed.string
             Job plenary.job
             vimp vimp}})

(defn- format-output [s]
  (utils.split (accumulate [final ""
                            _ o (ipairs s)]
                           (.. final o)) 
               "[\n\r]+"))



(defn- get-output-and-split [s]
  (vim.fn.jobstart s
                   {:on_stdout (fn [id data event]
                                 (if data
                                   (utils.to-temp-buffer data)))
                    :stdout_buffered true}))

(defn- uppercase [s]
  (string.gsub s "^." string.upper))

(defn- make-runner [ft of]
  (let [binary (. doom.langs ft of)
        cmd-name (.. "Runner" (uppercase of) (uppercase ft))]
    (when binary 

      ; In case if use-current-file is not ^y$ then simply return the string.
      (vimp.map_command cmd-name #(get-output-and-split (string.format "%s %s %s"
                                                                       binary 
                                                                       (vim.call :input (utils.fmt "Args for %s > " binary))
                                                                       (let [use-current-file (str.trim (vim.call :input "Use current file? (y/n) > "))
                                                                             file (if (string.match use-current-file "^y$")
                                                                                    (vim.fn.expand "%:p")
                                                                                    use-current-file)] file)))))))

(each [_ lang (ipairs (utils.keys doom.langs))]
  (each [_ op (ipairs [:build :test :compile])]
    (make-runner lang op)))

(utils.define-keys [{:keys "<leader>mc" :exec ":RunnerCompile" :help "Compile <lang>"}
                    {:keys "<leader>mb" :exec ":RunnerBuild" :help "Build <lang>"}
                    {:keys "<leader>mt" :exec ":RunnerTest" :help "Test <lang>"}])
