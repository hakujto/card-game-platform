-- :name get-all-draft-pick :? :*
-- :doc Get all Draft Pick records
SELECT id, pick_number, pack_number, picked_at, participant_id, card_id, created_at, updated_at FROM draft_picks

-- :name get-draft-pick-by-id :? :1
-- :doc Get a single Draft Pick by id
SELECT id, pick_number, pack_number, picked_at, participant_id, card_id, created_at, updated_at FROM draft_picks WHERE id = :id

-- :name delete-draft-pick! :! :n
-- :doc Delete a Draft Pick by id
DELETE FROM draft_picks WHERE id = :id
