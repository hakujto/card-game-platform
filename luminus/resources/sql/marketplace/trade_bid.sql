-- :name get-all-trade-bid :? :*
-- :doc Get all Trade Bid records
SELECT id, amount, placed_at, is_winning, listing_id, bidder_id, created_at, updated_at FROM trade_bids

-- :name get-trade-bid-by-id :? :1
-- :doc Get a single Trade Bid by id
SELECT id, amount, placed_at, is_winning, listing_id, bidder_id, created_at, updated_at FROM trade_bids WHERE id = :id

-- :name delete-trade-bid! :! :n
-- :doc Delete a Trade Bid by id
DELETE FROM trade_bids WHERE id = :id
