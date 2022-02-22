(local Dap {})
(local utils (require :utils))

(fn Dap.supports-dap [ft]
  (let [first-path (utils.path-exists (utils.datap "vimspector" ft))
        second-path (utils.path-exists (utils.confp "support" "vimspector" ft))]
    (if 
      first-path
      first-path

      second-path 
      second-path

      false)))

(fn Dap.copy-default-json [ft dest]
  (let [src (Dap.supports-dap ft)]

    (if src
      (do (utils.sh (string.format "cp %s/default.json %s/.vimspector.json"
                                   src 
                                   dest))
        true)
      false)))

(fn Dap.get-workspace-dir [s]
  (string.gsub s "/[^/]+$" ""))

(fn Dap.start-debugger []
  (when (Dap.copy-default-json vim.bo.filetype (Dap.get-workspace-dir (vim.fn.expand "%:p")))
    (vim.call "vimspector#Continue")))

(utils.define-keys [{:keys "<leader>dd" 
                     :exec Dap.start-debugger
                     :help "Start vimspector"}

                    {:keys "<leader>dk"
                     :exec ":call vimspector#Reset()<CR>"
                     :help "Reset vimspector"}

                    {:keys "<leader>dc"
                     :exec ":call vimspector#Continue()<CR>"
                     :help "Continue"}

                    {:keys "<leader>dn"
                     :exec ":call vimspector#StepOver()<CR>"
                     :help "Step over/next"}

                    {:keys "<leader>db"
                     :exec ":call vimspector#ToggleBreakpoint()<CR>"
                     :help "Toggle breakpoint"}

                    {:keys "<leader>dT"
                     :exec ":call vimspector#ClearBreakpoints()<CR>"
                     :help "Clear breakpoints"}

                    {:keys "<leader>df"
                     :exec ":call vimspector#StepOut()<CR>"
                     :help "Step out/finish"}

                    {:keys "<leader>ds"
                     :exec ":call vimspector#StepInto()<CR>"
                     :help "Step in/step"}])

Dap
