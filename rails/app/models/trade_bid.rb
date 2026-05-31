class TradeBid < ApplicationRecord
  self.table_name = 'trade_bids'

  belongs_to :listing, class_name: 'TradeListing'
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
    # TODO: implement outbid_by
    nil
  end

  def retract
    # TODO: implement retract
  end

  def as_json(options = {})
    hash = super(options)
    hash['placedAt'] = hash.delete('placed_at') if hash.key?('placed_at')
    hash
  end
end
