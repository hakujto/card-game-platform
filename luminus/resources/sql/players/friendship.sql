-- :name get-all-friendship :? :*
-- :doc Get all Friendship records
SELECT id, status, requester_id, receiver_id, created_at, updated_at FROM friendships

-- :name get-friendship-by-id :? :1
-- :doc Get a single Friendship by id
SELECT id, status, requester_id, receiver_id, created_at, updated_at FROM friendships WHERE id = :id

-- :name delete-friendship! :! :n
-- :doc Delete a Friendship by id
DELETE FROM friendships WHERE id = :id
