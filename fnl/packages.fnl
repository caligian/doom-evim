(module pkgs
  {autoload {utils utils
             pkg-utils package-utils
             Set Set
             fun fun
             core aniseed.core
             packer packer}})

(defn get-master-list []
  (let [default-packages doom.default_packages
        default-pkgs (utils.keys default-packages)
        default-pkgs (Set default-pkgs)

        current-packages doom.user_packages
        current-pkgs (utils.keys current-packages)
        current-pkgs (Set current-pkgs)

        new-pkgs     (utils.set-items (current-pkgs.difference default-pkgs))
        missing-pkgs (utils.set-items (default-pkgs.difference current-pkgs))
        remaining-pkgs (utils.set-items (current-pkgs.difference (Set new-pkgs)))
        doom-packages {}
        master-t []]

    ; Disable missing packages
    (when (> (length missing-pkgs) 0) 
      (each [_ k (ipairs missing-pkgs)]
        (tset default-packages k nil)))

    (when (> (length new-pkgs) 0)
      (each [_ k (ipairs new-pkgs)]
        (tset doom-packages k (. current-packages k))
        (table.insert master-t (. current-packages k))))

    (when (> (length remaining-pkgs) 0)
      (each [_ k (ipairs remaining-pkgs)]
        (tset doom-packages k (. current-packages k))
        (table.insert master-t (. current-packages k))))

    (set doom.packages doom-packages)
    master-t))

(get-master-list)
(require :specs)

; Setup packer
; SPC hrr can now reload packages!
(vim.cmd "packadd packer.nvim")
(packer.init {:git {:clone_timeout 300
                    :subcommands {:install "clone --depth %i --progress"} }
              :profile {:enable true}})

; Now setup everything
(packer.startup (fn [use]
                  (each [pkg conf (pairs doom.packages)]
                     (use conf))))

(utils.define-keys [{:keys "<leader>hpi" :exec packer.install :help "Install new"}
                    {:keys "<leader>hpu" :exec packer.update :help "Update current"}
                    {:keys "<leader>hpc" :exec packer.clean :help "Remove unused"}
                    {:keys "<leader>hps" :exec packer.sync :help "Sync current"}
                    {:keys "<leader>hpl" :exec packer.status :help "Show status"}
                    {:keys "<leader>hpw" :exec packer.compile :help "Compile current"}])
