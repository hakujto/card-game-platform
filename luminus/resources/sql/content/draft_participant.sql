-- :name get-all-draft-participant :? :*
-- :doc Get all Draft Participant records
SELECT id, seat_number, joined_at, session_id, player_id, drafted_cards_id, created_at, updated_at FROM draft_participants

-- :name get-draft-participant-by-id :? :1
-- :doc Get a single Draft Participant by id
SELECT id, seat_number, joined_at, session_id, player_id, drafted_cards_id, created_at, updated_at FROM draft_participants WHERE id = :id

-- :name delete-draft-participant! :! :n
-- :doc Delete a Draft Participant by id
DELETE FROM draft_participants WHERE id = :id
