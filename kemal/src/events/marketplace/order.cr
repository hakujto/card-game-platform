# src/events/marketplace/order.cr — domain events

struct OrderPaid
  property order_id : Int32
  property player_id : Int32
  property total : Float64
  property payment_method : String
  property paid_at : String
end

struct OrderShipped
  property order_id : Int32
  property tracking_number : String
  property shipped_at : String
end

struct OrderRefunded
  property order_id : Int32
  property refunded_at : String
end
