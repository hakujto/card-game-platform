(ns cards_project.db
  (:require [hugsql.core :as hugsql]
            [hugsql.adapter.next-jdbc :as next-adapter]
            [next.jdbc.result-set :as rs]))

; Set global HugSQL adapter once — returns plain unqualified keyword maps (:id not :table/id)
(hugsql/set-adapter! (next-adapter/hugsql-adapter-next-jdbc
                       {:options {:builder-fn rs/as-unqualified-lower-maps}}))

(def db-spec
  {:jdbcUrl (or (System/getenv "DATABASE_URL")
                "jdbc:sqlite:db/cards-project.db")})
