-- :name get-all-awarded-prize :? :*
-- :doc Get all Awarded Prize records
SELECT id, final_placement, awarded_at, claimed, claimed_at, prize_id, player_id, created_at, updated_at FROM awarded_prizes

-- :name get-awarded-prize-by-id :? :1
-- :doc Get a single Awarded Prize by id
SELECT id, final_placement, awarded_at, claimed, claimed_at, prize_id, player_id, created_at, updated_at FROM awarded_prizes WHERE id = :id

-- :name delete-awarded-prize! :! :n
-- :doc Delete a Awarded Prize by id
DELETE FROM awarded_prizes WHERE id = :id
