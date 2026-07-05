(ns cards_project.marketplace.order-events)

(defrecord OrderPaid [order_id player_id total payment_method paid_at])

(defrecord OrderShipped [order_id tracking_number shipped_at])

(defrecord OrderRefunded [order_id refunded_at])
