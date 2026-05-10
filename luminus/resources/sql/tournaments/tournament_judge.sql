-- :name get-all-tournament-judge :? :*
-- :doc Get all Tournament Judge records
SELECT id, role, tournament_id, player_id, created_at, updated_at FROM tournament_judges

-- :name get-tournament-judge-by-id :? :1
-- :doc Get a single Tournament Judge by id
SELECT id, role, tournament_id, player_id, created_at, updated_at FROM tournament_judges WHERE id = :id

-- :name delete-tournament-judge! :! :n
-- :doc Delete a Tournament Judge by id
DELETE FROM tournament_judges WHERE id = :id
