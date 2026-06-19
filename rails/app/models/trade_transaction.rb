class TradeTransaction < ApplicationRecord
  self.table_name = 'trade_transactions'

  enum :status, { pending: 0, completed: 1, disputed: 2, refunded: 3 }

  has_one :dispute, class_name: 'TradeDispute', inverse_of: :transaction_record
  belongs_to :listing, class_name: 'TradeListing', inverse_of: :transaction_record
  belongs_to :buyer, class_name: 'Player', inverse_of: :purchases
  belongs_to :seller, class_name: 'Player', inverse_of: :sales

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
    # TODO: implement complete
  end

  def refund
    # TODO: implement refund
  end

  def open_dispute(reason)
    # TODO: implement open_dispute
  end

  def seller_net
    # TODO: implement seller_net
    nil
  end

  def as_json(options = {})
    hash = super(options)
    hash['completedAt'] = hash.delete('completed_at') if hash.key?('completed_at')
    hash
  end
end
