class TradeBid < ApplicationRecord
  self.table_name = 'trade_bids'

  belongs_to :listing, class_name: 'Tradelisting'
  belongs_to :bidder, class_name: 'Player'

  # Domain invariants — simple rules
  validate :validate_rules

  def validate_rules
    errors.add(:amount_positive, 'Bid amount must be greater than zero') unless ((amount.nil? || amount.to_f > 0))
  end

  def to_s
    amount.to_s
  end

  # Business operations

  def outbid_by(new_amount)
    raise NotImplementedError, "outbid_by not implemented"
  end
end
