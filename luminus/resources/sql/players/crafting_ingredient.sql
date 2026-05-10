-- :name get-all-crafting-ingredient :? :*
-- :doc Get all Crafting Ingredient records
SELECT id, quantity, recipe_id, card_id, created_at, updated_at FROM crafting_ingredients

-- :name get-crafting-ingredient-by-id :? :1
-- :doc Get a single Crafting Ingredient by id
SELECT id, quantity, recipe_id, card_id, created_at, updated_at FROM crafting_ingredients WHERE id = :id

-- :name delete-crafting-ingredient! :! :n
-- :doc Delete a Crafting Ingredient by id
DELETE FROM crafting_ingredients WHERE id = :id
