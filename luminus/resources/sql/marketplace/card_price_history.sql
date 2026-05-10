-- :name get-all-card-price-history :? :*
-- :doc Get all Card Price History records
SELECT id, price_date, avg_price, min_price, max_price, volume, foil, card_id, created_at, updated_at FROM card_price_histories

-- :name get-card-price-history-by-id :? :1
-- :doc Get a single Card Price History by id
SELECT id, price_date, avg_price, min_price, max_price, volume, foil, card_id, created_at, updated_at FROM card_price_histories WHERE id = :id

-- :name delete-card-price-history! :! :n
-- :doc Delete a Card Price History by id
DELETE FROM card_price_histories WHERE id = :id
