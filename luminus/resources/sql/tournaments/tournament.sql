-- :name get-all-tournament :? :*
-- :doc Get all Tournament records
SELECT id, name, description, format, tournament_type, status, max_players, entry_fee, prize_pool, start_time, end_time, is_online, location, rules_text, season_id, organizer_id, created_at, updated_at FROM tournaments

-- :name get-tournament-by-id :? :1
-- :doc Get a single Tournament by id
SELECT id, name, description, format, tournament_type, status, max_players, entry_fee, prize_pool, start_time, end_time, is_online, location, rules_text, season_id, organizer_id, created_at, updated_at FROM tournaments WHERE id = :id

-- :name delete-tournament! :! :n
-- :doc Delete a Tournament by id
DELETE FROM tournaments WHERE id = :id
