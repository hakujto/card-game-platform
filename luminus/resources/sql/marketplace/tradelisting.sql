-- :name get-all-tradelisting :? :*
-- :doc Get all Tradelisting records
SELECT id, listing_type, asking_price, auction_start_price, auction_current_bid, auction_end_time, foil, condition, quantity, status, description, expires_at, seller_id, card_id, created_at, updated_at FROM tradelistings

-- :name get-tradelisting-by-id :? :1
-- :doc Get a single Tradelisting by id
SELECT id, listing_type, asking_price, auction_start_price, auction_current_bid, auction_end_time, foil, condition, quantity, status, description, expires_at, seller_id, card_id, created_at, updated_at FROM tradelistings WHERE id = :id

-- :name delete-tradelisting! :! :n
-- :doc Delete a Tradelisting by id
DELETE FROM tradelistings WHERE id = :id
