-- :name get-all-crafting-recipe :? :*
-- :doc Get all Crafting Recipe records
SELECT id, dust_cost, is_available, result_card_id, created_at, updated_at FROM crafting_recipes

-- :name get-crafting-recipe-by-id :? :1
-- :doc Get a single Crafting Recipe by id
SELECT id, dust_cost, is_available, result_card_id, created_at, updated_at FROM crafting_recipes WHERE id = :id

-- :name delete-crafting-recipe! :! :n
-- :doc Delete a Crafting Recipe by id
DELETE FROM crafting_recipes WHERE id = :id
