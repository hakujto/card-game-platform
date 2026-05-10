-- :name get-all-card-ruling :? :*
-- :doc Get all Card Ruling records
SELECT id, ruling_text, published_at, source, card_id, created_at, updated_at FROM card_rulings

-- :name get-card-ruling-by-id :? :1
-- :doc Get a single Card Ruling by id
SELECT id, ruling_text, published_at, source, card_id, created_at, updated_at FROM card_rulings WHERE id = :id

-- :name delete-card-ruling! :! :n
-- :doc Delete a Card Ruling by id
DELETE FROM card_rulings WHERE id = :id
