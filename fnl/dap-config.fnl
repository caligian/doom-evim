(module dap-config
  {autoload {utils utils}})

(defn install-default []
  (each [lang debugger (pairs doom.dap.default)]
    (utils.exec ":VimspectorInstall %s" debugger)))

(defn supports-dap [ft]
  (let [path (string.format "%s/support/vimspector/%s" 
                            (vim.fn.stdpath "config")
                            ft)
        exists (utils.path-exists path)]
    (if exists
      path
      false)))

(defn copy-default-json [ft dest]
  (let [src (supports-dap ft)]
    (utils.sh (string.format "cp %s/default.json %s/.vimspector.json"
                             src 
                             dest))))

(defn get-workspace-dir [s]
  (string.gsub s "/[^/]+$" ""))

(defn start-debugger []
  (when (copy-default-json vim.bo.filetype (get-workspace-dir (vim.fn.expand "%:p")))
    (vim.call "vimspector#Launch")))

(utils.define-keys [{:keys "<leader>dd" 
                     :exec start-debugger
                     :help "Start vimspector"}

                    {:keys "<leader>dK" 
                     :exec #(vim.cmd ":VimspectorReset")
                     :help "Reset vimspector"}])
