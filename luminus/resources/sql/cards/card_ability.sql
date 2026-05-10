-- :name get-all-card-ability :? :*
-- :doc Get all Card Ability records
SELECT id, ability_type, keyword, ability_text, timing, card_id, created_at, updated_at FROM card_abilities

-- :name get-card-ability-by-id :? :1
-- :doc Get a single Card Ability by id
SELECT id, ability_type, keyword, ability_text, timing, card_id, created_at, updated_at FROM card_abilities WHERE id = :id

-- :name delete-card-ability! :! :n
-- :doc Delete a Card Ability by id
DELETE FROM card_abilities WHERE id = :id
