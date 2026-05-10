-- :name get-all-deck-tag-assignment :? :*
-- :doc Get all Deck Tag Assignment records
SELECT id, deck_id, tag_id, created_at, updated_at FROM deck_tag_assignments

-- :name get-deck-tag-assignment-by-id :? :1
-- :doc Get a single Deck Tag Assignment by id
SELECT id, deck_id, tag_id, created_at, updated_at FROM deck_tag_assignments WHERE id = :id

-- :name delete-deck-tag-assignment! :! :n
-- :doc Delete a Deck Tag Assignment by id
DELETE FROM deck_tag_assignments WHERE id = :id
