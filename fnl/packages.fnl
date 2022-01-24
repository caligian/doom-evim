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

(packer.startup (fn [use]
                  (each [pkg conf (ipairs (get-master-list))]
                     (use conf))))
