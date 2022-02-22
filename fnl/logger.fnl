(local Logger {})
(local file-logger (require :logging.file))
(local path (require :path))
(global log-path (path (vim.fn.stdpath "data") "doom-evim.log"))

(fn Logger.log [level message]
  (let [logger (file-logger log-path "%d-%m-%Y-%H-%M-%S" "[%date] [%level] %message\n")]
    (match level
      :debug (logger:debug message)
      :info  (logger:info message)
      :error (logger:error message)
      :fatal (logger:fatal message)
      :warn  (logger:warn message))))

(fn Logger.dlog [message] (Logger.log :debug message))
(fn Logger.elog [message] (Logger.log :error message))
(fn Logger.flog [message] (Logger.log :fatal message))
(fn Logger.ilog [message] (Logger.log :info message))

Logger
