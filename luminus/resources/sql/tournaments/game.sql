-- :name get-all-game :? :*
-- :doc Get all Game records
SELECT id, game_number, winner_side, turns_played, duration_seconds, ended_by, replay_url, match_id, winner_id, created_at, updated_at FROM games

-- :name get-game-by-id :? :1
-- :doc Get a single Game by id
SELECT id, game_number, winner_side, turns_played, duration_seconds, ended_by, replay_url, match_id, winner_id, created_at, updated_at FROM games WHERE id = :id

-- :name delete-game! :! :n
-- :doc Delete a Game by id
DELETE FROM games WHERE id = :id
