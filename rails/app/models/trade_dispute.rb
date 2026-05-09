class TradeDispute < ApplicationRecord
  self.table_name = 'trade_disputes'

  enum :reason, { item_not_received: 0, item_not_as_described: 1, fraud_suspected: 2, other: 3 }, prefix: :reason
  enum :status, { open: 0, under_review: 1, resolved: 2, escalated: 3 }, prefix: :status

  belongs_to :transaction_record, class_name: 'TradeTransaction', foreign_key: :transaction_id
  belongs_to :opened_by, class_name: 'Player'
  belongs_to :resolved_by, class_name: 'Player', optional: true

  def to_s
    reason.to_s
  end
end
