-- :name get-all-order :? :*
-- :doc Get all Order records
SELECT id, status, total, discount_applied, currency, payment_method, payment_reference, shipping_address, tracking_number, paid_at, shipped_at, player_id, items_id, coupon_id, created_at, updated_at FROM orders

-- :name get-order-by-id :? :1
-- :doc Get a single Order by id
SELECT id, status, total, discount_applied, currency, payment_method, payment_reference, shipping_address, tracking_number, paid_at, shipped_at, player_id, items_id, coupon_id, created_at, updated_at FROM orders WHERE id = :id

-- :name delete-order! :! :n
-- :doc Delete a Order by id
DELETE FROM orders WHERE id = :id
