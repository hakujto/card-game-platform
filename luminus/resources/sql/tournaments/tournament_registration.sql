-- :name get-all-tournament-registration :? :*
-- :doc Get all Tournament Registration records
SELECT id, status, seed, final_standing, points_earned, registered_at, tournament_id, player_id, deck_id, created_at, updated_at FROM tournament_registrations

-- :name get-tournament-registration-by-id :? :1
-- :doc Get a single Tournament Registration by id
SELECT id, status, seed, final_standing, points_earned, registered_at, tournament_id, player_id, deck_id, created_at, updated_at FROM tournament_registrations WHERE id = :id

-- :name delete-tournament-registration! :! :n
-- :doc Delete a Tournament Registration by id
DELETE FROM tournament_registrations WHERE id = :id
