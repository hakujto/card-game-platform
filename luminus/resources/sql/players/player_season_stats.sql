-- :name get-all-player-season-stats :? :*
-- :doc Get all Player Season Stats records
SELECT id, wins, losses, draws, tournament_wins, highest_rank, season_points, player_id, season_id, created_at, updated_at FROM player_season_statses

-- :name get-player-season-stats-by-id :? :1
-- :doc Get a single Player Season Stats by id
SELECT id, wins, losses, draws, tournament_wins, highest_rank, season_points, player_id, season_id, created_at, updated_at FROM player_season_statses WHERE id = :id

-- :name delete-player-season-stats! :! :n
-- :doc Delete a Player Season Stats by id
DELETE FROM player_season_statses WHERE id = :id
