-- :name get-all-tournament-round :? :*
-- :doc Get all Tournament Round records
SELECT id, round_number, status, started_at, ended_at, time_limit_minutes, tournament_id, matches_id, created_at, updated_at FROM tournament_rounds

-- :name get-tournament-round-by-id :? :1
-- :doc Get a single Tournament Round by id
SELECT id, round_number, status, started_at, ended_at, time_limit_minutes, tournament_id, matches_id, created_at, updated_at FROM tournament_rounds WHERE id = :id

-- :name delete-tournament-round! :! :n
-- :doc Delete a Tournament Round by id
DELETE FROM tournament_rounds WHERE id = :id
