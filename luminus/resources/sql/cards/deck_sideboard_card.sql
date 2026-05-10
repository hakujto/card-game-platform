-- :name get-all-deck-sideboard-card :? :*
-- :doc Get all Deck Sideboard Card records
SELECT id, quantity, deck_id, card_id, created_at, updated_at FROM deck_sideboard_cards

-- :name get-deck-sideboard-card-by-id :? :1
-- :doc Get a single Deck Sideboard Card by id
SELECT id, quantity, deck_id, card_id, created_at, updated_at FROM deck_sideboard_cards WHERE id = :id

-- :name delete-deck-sideboard-card! :! :n
-- :doc Delete a Deck Sideboard Card by id
DELETE FROM deck_sideboard_cards WHERE id = :id
