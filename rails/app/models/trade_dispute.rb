class TradeDispute < ApplicationRecord
  self.table_name = 'trade_disputes'

  enum :reason, { item_not_received: 0, item_not_as_described: 1, fraud_suspected: 2, other: 3 }, prefix: :reason
  enum :status, { open: 0, under_review: 1, resolved: 2, escalated: 3 }, prefix: :status

  belongs_to :transaction_record, class_name: 'TradeTransaction', foreign_key: :transaction_id
  belongs_to :opened_by, class_name: 'Player'
  belongs_to :resolved_by, class_name: 'Player', optional: true

  # Domain invariants — IMPLIES rules
  validate :validate_implies

  def validate_implies
    errors.add(:base, 'resolved_at_requires_terminal_status') if (!resolved_at.nil?) && !(status == 'resolved')
  end

  def to_s
    reason.to_s
  end

  # Business operations

  def escalate
    raise NotImplementedError, "escalate not implemented"
  end

  def resolve(resolution_text)
    raise NotImplementedError, "resolve not implemented"
  end

  def review
    raise NotImplementedError, "review not implemented"
  end
end
