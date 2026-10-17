# src/events/marketplace/trade_transaction.cr — domain events

struct TransactionCompleted
  property transaction_id : Int32
  property buyer_id : Int32
  property seller_id : Int32
  property final_price : Float64
  property completed_at : String
end
