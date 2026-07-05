module Events
  module Marketplace
    TransactionCompleted = Struct.new(
      :transaction_id, :buyer_id, :seller_id, :final_price, :completed_at,
      keyword_init: true
    )
  end
end