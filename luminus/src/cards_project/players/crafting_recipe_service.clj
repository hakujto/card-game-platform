(ns cards_project.players.crafting-recipe-service
  (:require [next.jdbc :as jdbc]
            [next.jdbc.result-set :as rs]
            [cards_project.players.crafting-recipe-queries :as queries]
            [cards_project.db :refer [db-spec]]))

(defn validate-crafting-recipe
  "Validate and transform params before persistence."
  [params]
  params)

; ── Domain behavior stubs ──────────────────────────────────────────
(defn- can-craft-behavior! [id player-id]
  ; TODO: implement can_craft
  nil)

(defn- execute-craft-behavior! [id player-id]
  ; TODO: implement execute_craft
  nil)

(defn- disable-behavior! [id]
  ; TODO: implement disable
  nil)

(defn- enable-behavior! [id]
  ; TODO: implement enable
  nil)

(defn can-craft!
  [id player-id]
  (if (queries/get-crafting-recipe-by-id db-spec {:id id})
    (can-craft-behavior! id player-id)
    (throw (ex-info "CraftingRecipe not found" {:id id}))))

(defn execute-craft!
  [id player-id]
  (if (queries/get-crafting-recipe-by-id db-spec {:id id})
    (execute-craft-behavior! id player-id)
    (throw (ex-info "CraftingRecipe not found" {:id id}))))

(defn disable!
  [id]
  (if (queries/get-crafting-recipe-by-id db-spec {:id id})
    (disable-behavior! id)
    (throw (ex-info "CraftingRecipe not found" {:id id}))))

(defn enable!
  [id]
  (if (queries/get-crafting-recipe-by-id db-spec {:id id})
    (enable-behavior! id)
    (throw (ex-info "CraftingRecipe not found" {:id id}))))

