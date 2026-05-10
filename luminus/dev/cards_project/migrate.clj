(ns cards_project.migrate
  (:require [migratus.core :as migratus]))

(def config
  {:store         :database
   :migration-dir "migrations"
   :db {:jdbcUrl (or (System/getenv "DATABASE_URL")
                     "jdbc:sqlite:db/cards-project.db")}})

(defn -main [& [cmd]]
  (case cmd
    "rollback" (do (println "Rolling back last migration...")
                   (migratus/rollback config)
                   (println "Done."))
    (do (println "Running migrations...")
        (migratus/migrate config)
        (println "Done."))))
