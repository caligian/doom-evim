(local Packages {})
(local utils (require :utils))
(local core (require :aniseed.core))
(local packer (require :packer))

(fn Packages.setup []
  (set doom.packages (vim.tbl_extend :force doom.user_packages doom.essential_packages))
  (require :specs)
  (require :user-specs)

  ; Setup packer
  ; SPC hrr can now reload packages!
  (vim.cmd "packadd packer.nvim")

  (packer.reset)

  (packer.init {:git {:clone_timeout 300
                      :subcommands {:install "clone --depth %i --progress"} }
                :profile {:enable true}})

  ; Now setup everything
  (packer.startup (fn [use]
                    (each [_ conf (pairs doom.packages)]
                      (use conf))))

  (utils.define-keys [{:keys "<leader>hpi" :exec packer.install :help "Install new"}
                      {:keys "<leader>hpu" :exec packer.update :help "Update current"}
                      {:keys "<leader>hpc" :exec packer.clean :help "Remove unused"}
                      {:keys "<leader>hps" :exec packer.sync :help "Sync current"}
                      {:keys "<leader>hpl" :exec packer.status :help "Show status"}
                      {:keys "<leader>hpw" :exec packer.compile :help "Compile current"}]))

Packages
