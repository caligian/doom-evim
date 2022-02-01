(module dap-config
  {autoload {utils utils}})

(defn install-default []
  (each [lang debugger (pairs doom.dap.default)]
    (utils.exec ":VimspectorInstall %s" debugger)))

(defn- supports-dap [ft]
  (let [first-path (utils.path-exists (utils.datap "vimspector" ft))
        second-path (utils.path-exists (utils.confp "support" "vimspector" ft))]
    (if 
      first-path
      first-path

      second-path 
      second-path

      false)))

(defn- copy-default-json [ft dest]
  (let [src (supports-dap ft)]

    (if src
      (do (utils.sh (string.format "cp %s/default.json %s/.vimspector.json"
                                   src 
                                   dest))
        true)
      false)))

(defn- get-workspace-dir [s]
  (string.gsub s "/[^/]+$" ""))

(defn- start-debugger []
  (when (copy-default-json vim.bo.filetype (get-workspace-dir (vim.fn.expand "%:p")))
    (vim.call "vimspector#Continue")))

(utils.define-keys [{:keys "<leader>dd" 
                     :exec start-debugger
                     :help "Start vimspector"}

                    {:keys "<leader>dK" 
                     :exec #(vim.cmd ":VimspectorReset")
                     :help "Reset vimspector"}])
