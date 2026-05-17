-- :name get-all-player :? :*
-- :doc Get all Player records
SELECT id, display_name, rank, rating, peak_rating, bio, country_code, avatar_url, preferred_format, is_verified, last_active_at, user_id, created_at, updated_at FROM players

-- :name get-player-by-id :? :1
-- :doc Get a single Player by id
SELECT id, display_name, rank, rating, peak_rating, bio, country_code, avatar_url, preferred_format, is_verified, last_active_at, user_id, created_at, updated_at FROM players WHERE id = :id

-- :name delete-player! :! :n
-- :doc Delete a Player by id
DELETE FROM players WHERE id = :id
