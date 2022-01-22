(module runners
  {autoload {utils utils
             core aniseed.core
             str aniseed.string
             vimp vimp}})

(local make-keys-t {:test {:keys "<leader>mt"
                           :help "Run ft test suite"}
                    :compile {:keys "<leader>mc"
                              :help "Run ft compiler"}
                    :build {:keys "<leader>mb"
                            :help "Build current file"}})

(defn- format-output [s]
  (utils.split (accumulate [final ""
                            _ o (ipairs s)]
                           (.. final o)) 
               "[\n\r]+"))

(defn- get-output-and-split [s]
  (let [s (vim.call :system s)
        s (if (= (type s) "table")
            (format-output s)
            (utils.split s "[\n\r]+"))]
    (utils.to-temp-buffer s :sp)))

(defn- uppercase [s]
  (string.gsub s "^." string.upper))

(defn- make-runner [ft of keys help]
  (let [binary (. doom.langs ft of)
        pattern (. doom.langs ft :pattern)
        f #(get-output-and-split (string.format "%s %s %s"
                                                binary
                                                (vim.call :input (utils.fmt "Args for %s > " binary))
                                                (vim.fn.expand "%:p")))
        cmd-name (.. "Runner" (uppercase of) (uppercase ft))]
    (when binary 
      (vimp.map_command cmd-name f)
      (utils.define-key {:keys keys :patterns pattern :exec (.. ":" cmd-name "<CR>") :help help :key-attribs ["buffer"] :events "WinEnter"}))))

(each [_ lang (ipairs (utils.keys doom.langs))]
  (each [_ op (ipairs [:build :test :compile])]
    (let [keys (. make-keys-t op :keys)
          help (. make-keys-t op :help)]
      (make-runner lang op keys help))))
