class TradeListing < ApplicationRecord
  self.table_name = 'trade_listings'

  enum :listing_type, { fixed_price: 0, auction: 1, trade_offer: 2 }, prefix: :listing_type
  enum :condition, { mint: 0, near_mint: 1, excellent: 2, good: 3, played: 4 }, prefix: :condition
  enum :status, { active: 0, sold: 1, expired: 2, cancelled: 3, pending: 4 }, prefix: :status

  belongs_to :seller, class_name: 'Player'
  belongs_to :card, class_name: 'Card'

  # Domain invariants — simple rules
  validate :validate_rules

  def validate_rules
    errors.add(:quantity_positive, 'Listing quantity must be between 1 and 9999') unless ((quantity.nil? || (quantity >= 1 && quantity <= 9999)))
  end

  # Domain invariants — IMPLIES rules
  validate :validate_implies

  def validate_implies
    errors.add(:base, 'Fixed price listing must have an asking price') if (listing_type == 'fixed_price') && asking_price.nil?
    errors.add(:base, 'Auction listing must have a start price and end time') if (listing_type == 'auction') && !(!auction_start_price.nil? && !auction_end_time.nil?)
  end

  def to_s
    listing_type.to_s
  end

  # Business operations

  def close
    raise NotImplementedError, "close not implemented"
  end

  def extend(days)
    raise NotImplementedError, "extend not implemented"
  end

  def cancel
    raise NotImplementedError, "cancel not implemented"
  end

  def is_expired
    raise NotImplementedError, "is_expired not implemented"
  end

  def finalize_auction
    raise NotImplementedError, "finalize_auction not implemented"
  end
end
