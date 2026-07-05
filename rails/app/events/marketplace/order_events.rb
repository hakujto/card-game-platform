module Events
  module Marketplace
    OrderPaid = Struct.new(
      :order_id, :player_id, :total, :payment_method, :paid_at,
      keyword_init: true
    )
    OrderShipped = Struct.new(
      :order_id, :tracking_number, :shipped_at,
      keyword_init: true
    )
    OrderRefunded = Struct.new(
      :order_id, :refunded_at,
      keyword_init: true
    )
  end
end