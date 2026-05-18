class TradeTransaction < ApplicationRecord
  self.table_name = 'trade_transactions'

  enum :status, { pending: 0, completed: 1, disputed: 2, refunded: 3 }

  belongs_to :listing, class_name: 'TradeListing'
  belongs_to :buyer, class_name: 'Player'
  belongs_to :seller, class_name: 'Player'

  # Domain invariants — simple rules
  validate :validate_rules

  def validate_rules
    errors.add(:fee_not_exceed_price, 'Platform fee cannot exceed the final price') unless ((platform_fee.nil? || (!final_price.nil? && platform_fee.to_f <= final_price.to_f)))
    errors.add(:fee_not_negative, 'Platform fee must not be negative') unless ((platform_fee.nil? || platform_fee.to_f >= 0))
    errors.add(:final_price_positive, 'Transaction final price must be greater than zero') unless ((final_price.nil? || final_price.to_f > 0))
  end

  # Domain invariants — IMPLIES rules
  validate :validate_implies

  def validate_implies
    errors.add(:base, 'Completed transaction must have a completed_at timestamp') if (status == 'completed') && completed_at.nil?
  end

  def to_s
    final_price.to_s
  end

  # Business operations

  def complete
    raise NotImplementedError, "complete not implemented"
  end

  def refund
    raise NotImplementedError, "refund not implemented"
  end

  def open_dispute(reason)
    raise NotImplementedError, "open_dispute not implemented"
  end

  def seller_net
    raise NotImplementedError, "seller_net not implemented"
  end
end
