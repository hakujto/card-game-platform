-- :name get-all-player-achievement :? :*
-- :doc Get all Player Achievement records
SELECT id, earned_at, progress, is_completed, player_id, achievement_id, created_at, updated_at FROM player_achievements

-- :name get-player-achievement-by-id :? :1
-- :doc Get a single Player Achievement by id
SELECT id, earned_at, progress, is_completed, player_id, achievement_id, created_at, updated_at FROM player_achievements WHERE id = :id

-- :name delete-player-achievement! :! :n
-- :doc Delete a Player Achievement by id
DELETE FROM player_achievements WHERE id = :id
