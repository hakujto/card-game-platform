-- :name get-all-order-item :? :*
-- :doc Get all Order Item records
SELECT id, quantity, price_at_purchase, foil, order_id, product_id, created_at, updated_at FROM order_items

-- :name get-order-item-by-id :? :1
-- :doc Get a single Order Item by id
SELECT id, quantity, price_at_purchase, foil, order_id, product_id, created_at, updated_at FROM order_items WHERE id = :id

-- :name delete-order-item! :! :n
-- :doc Delete a Order Item by id
DELETE FROM order_items WHERE id = :id
