-- :name get-all-coupon :? :*
-- :doc Get all Coupon records
SELECT id, code, discount_type, discount_value, min_order_value, max_uses, uses_count, valid_from, valid_until, is_active, created_at, updated_at FROM coupons

-- :name get-coupon-by-id :? :1
-- :doc Get a single Coupon by id
SELECT id, code, discount_type, discount_value, min_order_value, max_uses, uses_count, valid_from, valid_until, is_active, created_at, updated_at FROM coupons WHERE id = :id

-- :name delete-coupon! :! :n
-- :doc Delete a Coupon by id
DELETE FROM coupons WHERE id = :id
