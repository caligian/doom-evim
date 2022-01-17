(module pkgs
  {autoload {utils utils
             pkg-utils package-utils
             packer packer
             Set Set}})

(packer.startup (fn [use]
                  (each [_ conf (ipairs (pkg-utils.get-master-list))]
                    (use conf))))
