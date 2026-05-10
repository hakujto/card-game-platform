-- :name get-all-trade-dispute :? :*
-- :doc Get all Trade Dispute records
SELECT id, reason, description, status, resolution, opened_at, resolved_at, transaction_id, opened_by_id, resolved_by_id, created_at, updated_at FROM trade_disputes

-- :name get-trade-dispute-by-id :? :1
-- :doc Get a single Trade Dispute by id
SELECT id, reason, description, status, resolution, opened_at, resolved_at, transaction_id, opened_by_id, resolved_by_id, created_at, updated_at FROM trade_disputes WHERE id = :id

-- :name delete-trade-dispute! :! :n
-- :doc Delete a Trade Dispute by id
DELETE FROM trade_disputes WHERE id = :id
