-- :name get-all-trade-transaction :? :*
-- :doc Get all Trade Transaction records
SELECT id, final_price, platform_fee, status, completed_at, listing_id, buyer_id, seller_id, created_at, updated_at FROM trade_transactions

-- :name get-trade-transaction-by-id :? :1
-- :doc Get a single Trade Transaction by id
SELECT id, final_price, platform_fee, status, completed_at, listing_id, buyer_id, seller_id, created_at, updated_at FROM trade_transactions WHERE id = :id

-- :name delete-trade-transaction! :! :n
-- :doc Delete a Trade Transaction by id
DELETE FROM trade_transactions WHERE id = :id
