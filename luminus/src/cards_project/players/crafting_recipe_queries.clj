(ns cards_project.players.crafting-recipe-queries
  (:require [hugsql.core :as hugsql]
            [cards_project.db]))   ; loads set-adapter! side effect

(hugsql/def-db-fns "sql/players/crafting_recipe.sql")
