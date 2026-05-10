-- :name get-all-deck :? :*
-- :doc Get all Deck records
SELECT id, name, description, format, is_public, is_tournament_legal, archetype, wins, losses, player_id, created_at, updated_at FROM decks

-- :name get-deck-by-id :? :1
-- :doc Get a single Deck by id
SELECT id, name, description, format, is_public, is_tournament_legal, archetype, wins, losses, player_id, created_at, updated_at FROM decks WHERE id = :id

-- :name delete-deck! :! :n
-- :doc Delete a Deck by id
DELETE FROM decks WHERE id = :id
