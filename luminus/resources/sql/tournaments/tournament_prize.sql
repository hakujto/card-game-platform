-- :name get-all-tournament-prize :? :*
-- :doc Get all Tournament Prize records
SELECT id, placement_from, placement_to, prize_type, amount, description, packs_count, season_points, tournament_id, created_at, updated_at FROM tournament_prizes

-- :name get-tournament-prize-by-id :? :1
-- :doc Get a single Tournament Prize by id
SELECT id, placement_from, placement_to, prize_type, amount, description, packs_count, season_points, tournament_id, created_at, updated_at FROM tournament_prizes WHERE id = :id

-- :name delete-tournament-prize! :! :n
-- :doc Delete a Tournament Prize by id
DELETE FROM tournament_prizes WHERE id = :id
