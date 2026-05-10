-- :name get-all-card-set :? :*
-- :doc Get all Card Set records
SELECT id, name, code, release_date, set_type, total_cards, description, logo_url, created_at, updated_at FROM card_sets

-- :name get-card-set-by-id :? :1
-- :doc Get a single Card Set by id
SELECT id, name, code, release_date, set_type, total_cards, description, logo_url, created_at, updated_at FROM card_sets WHERE id = :id

-- :name delete-card-set! :! :n
-- :doc Delete a Card Set by id
DELETE FROM card_sets WHERE id = :id
