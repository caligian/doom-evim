(module pkgs
  {autoload {utils utils
             Set Set}})

(local packer (require :packer))

(defn get-master-list []
  (let [default-packages (utils.get-default-pkgs)
        default-pkgs (utils.keys default-packages)
        default-pkgs (Set default-pkgs)

        current-packages (utils.get-current-pkgs)
        current-pkgs (utils.keys current-packages)
        current-pkgs (Set current-pkgs)

        new-pkgs     (utils.set-items (current-pkgs.difference default-pkgs))
        missing-pkgs (utils.set-items (default-pkgs.difference current-pkgs))
        remaining-pkgs (utils.set-items (current-pkgs.difference (Set new-pkgs)))
        master-t []]

    ; Disable missing packages
    (when (> (length missing-pkgs) 0) 
      (each [_ k (ipairs missing-pkgs)]
        (tset default-packages k nil)))

    (when (> (length new-pkgs) 0)
      (each [_ k (ipairs new-pkgs)]
        (table.insert master-t (. current-packages k))))

    (when (> (length remaining-pkgs) 0)
      (each [_ k (ipairs remaining-pkgs)]
        (table.insert master-t (. current-packages k))))
    (tset doom :packages master-t)
    master-t))

(packer.startup (fn [use]
                  (each [_ conf (ipairs (get-master-list))]
                    (use conf))))
