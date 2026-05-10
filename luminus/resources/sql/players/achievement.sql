-- :name get-all-achievement :? :*
-- :doc Get all Achievement records
SELECT id, name, description, icon_url, points, rarity, is_hidden, created_at, updated_at FROM achievements

-- :name get-achievement-by-id :? :1
-- :doc Get a single Achievement by id
SELECT id, name, description, icon_url, points, rarity, is_hidden, created_at, updated_at FROM achievements WHERE id = :id

-- :name delete-achievement! :! :n
-- :doc Delete a Achievement by id
DELETE FROM achievements WHERE id = :id
