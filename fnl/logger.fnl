(module logger)

(local file-logger (require :logging.file))
(local path (require :path))
;
(global log-path (path (vim.fn.stdpath "data") "doom-evim.log"))

(defn log [level message]
  (let [logger (file-logger log-path "%d-%m-%Y-%H-%M-%S" "[%date] [%level] %message\n")]
    (match level
      :debug (logger:debug message)
      :info  (logger:info message)
      :error (logger:error message)
      :fatal (logger:fatal message)
      :warn  (logger:warn message))))

(defn dlog [message] (log :debug message))
(defn elog [message] (log :error message))
(defn flog [message] (log :fatal message))
(defn ilog [message] (log :info message))
