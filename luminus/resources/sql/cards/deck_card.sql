-- :name get-all-deck-card :? :*
-- :doc Get all Deck Card records
SELECT id, quantity, is_commander, deck_id, card_id, created_at, updated_at FROM deck_cards

-- :name get-deck-card-by-id :? :1
-- :doc Get a single Deck Card by id
SELECT id, quantity, is_commander, deck_id, card_id, created_at, updated_at FROM deck_cards WHERE id = :id

-- :name delete-deck-card! :! :n
-- :doc Delete a Deck Card by id
DELETE FROM deck_cards WHERE id = :id
