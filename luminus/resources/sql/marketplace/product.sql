-- :name get-all-product :? :*
-- :doc Get all Product records
SELECT id, name, product_type, price, stock, active, discount_percent, description, image_url, featured, card_id, card_set_id, created_at, updated_at FROM products

-- :name get-product-by-id :? :1
-- :doc Get a single Product by id
SELECT id, name, product_type, price, stock, active, discount_percent, description, image_url, featured, card_id, card_set_id, created_at, updated_at FROM products WHERE id = :id

-- :name delete-product! :! :n
-- :doc Delete a Product by id
DELETE FROM products WHERE id = :id
