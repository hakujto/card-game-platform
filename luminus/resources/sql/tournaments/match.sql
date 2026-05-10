-- :name get-all-match :? :*
-- :doc Get all Match records
SELECT id, table_number, status, player1_wins, player2_wins, started_at, ended_at, result_notes, round_id, player1_id, player2_id, games_id, created_at, updated_at FROM matches

-- :name get-match-by-id :? :1
-- :doc Get a single Match by id
SELECT id, table_number, status, player1_wins, player2_wins, started_at, ended_at, result_notes, round_id, player1_id, player2_id, games_id, created_at, updated_at FROM matches WHERE id = :id

-- :name delete-match! :! :n
-- :doc Delete a Match by id
DELETE FROM matches WHERE id = :id
