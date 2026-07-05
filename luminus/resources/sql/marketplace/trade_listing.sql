-- :name get-all-trade-listing :? :*
-- :doc Get all Trade Listing records
SELECT id, public_id, status, listing_type, asking_price, auction_start_price, auction_current_bid, auction_end_time, foil, condition, quantity, description, expires_at, seller_id, card_id, created_at, updated_at FROM trade_listings

-- :name get-trade-listing-by-id :? :1
-- :doc Get a single Trade Listing by id
SELECT id, public_id, status, listing_type, asking_price, auction_start_price, auction_current_bid, auction_end_time, foil, condition, quantity, description, expires_at, seller_id, card_id, created_at, updated_at FROM trade_listings WHERE id = :id

-- :name delete-trade-listing! :! :n
-- :doc Delete a Trade Listing by id
DELETE FROM trade_listings WHERE id = :id
