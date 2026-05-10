-- :name get-all-draft-session :? :*
-- :doc Get all Draft Session records
SELECT id, status, draft_type, seats, completed_at, card_set_id, participants_id, created_at, updated_at FROM draft_sessions

-- :name get-draft-session-by-id :? :1
-- :doc Get a single Draft Session by id
SELECT id, status, draft_type, seats, completed_at, card_set_id, participants_id, created_at, updated_at FROM draft_sessions WHERE id = :id

-- :name delete-draft-session! :! :n
-- :doc Delete a Draft Session by id
DELETE FROM draft_sessions WHERE id = :id
