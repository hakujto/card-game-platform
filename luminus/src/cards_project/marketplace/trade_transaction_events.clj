(ns cards_project.marketplace.trade-transaction-events)

(defrecord TransactionCompleted [transaction_id buyer_id seller_id final_price completed_at])
