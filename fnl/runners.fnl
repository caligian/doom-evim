(module runners
  {autoload {utils utils
             core aniseed.core
             str aniseed.string
             vimp vimp}})

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

(defn- make-runner [ft of]
  (let [binary (. doom.langs ft of)
        cmd-name (.. "Runner" (uppercase of) (uppercase ft))]
    (when binary 
      (vimp.map_command cmd-name #(get-output-and-split (string.format "%s %s %s"
                                                                       (. binary of)
                                                                       (vim.call :input (utils.fmt "Args for %s > " (. binary of)))
                                                                       (vim.fn.expand "%:p"))) f))))

(each [_ lang (ipairs (utils.keys doom.langs))]
  (each [_ op (ipairs [:build :test :compile])]
    (make-runner lang op)))
