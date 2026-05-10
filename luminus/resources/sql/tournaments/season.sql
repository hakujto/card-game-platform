-- :name get-all-season :? :*
-- :doc Get all Season records
SELECT id, name, start_date, end_date, format, is_active, reward_description, created_at, updated_at FROM seasons

-- :name get-season-by-id :? :1
-- :doc Get a single Season by id
SELECT id, name, start_date, end_date, format, is_active, reward_description, created_at, updated_at FROM seasons WHERE id = :id

-- :name delete-season! :! :n
-- :doc Delete a Season by id
DELETE FROM seasons WHERE id = :id
