-- :name get-all-deck-tag :? :*
-- :doc Get all Deck Tag records
SELECT id, name, color, created_at, updated_at FROM deck_tags

-- :name get-deck-tag-by-id :? :1
-- :doc Get a single Deck Tag by id
SELECT id, name, color, created_at, updated_at FROM deck_tags WHERE id = :id

-- :name delete-deck-tag! :! :n
-- :doc Delete a Deck Tag by id
DELETE FROM deck_tags WHERE id = :id
