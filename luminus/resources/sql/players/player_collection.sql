-- :name get-all-player-collection :? :*
-- :doc Get all Player Collection records
SELECT id, quantity, foil, condition, acquired_at, acquired_via, player_id, card_id, created_at, updated_at FROM player_collections

-- :name get-player-collection-by-id :? :1
-- :doc Get a single Player Collection by id
SELECT id, quantity, foil, condition, acquired_at, acquired_via, player_id, card_id, created_at, updated_at FROM player_collections WHERE id = :id

-- :name delete-player-collection! :! :n
-- :doc Delete a Player Collection by id
DELETE FROM player_collections WHERE id = :id
