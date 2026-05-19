class TradeListing < ApplicationRecord
  self.table_name = 'trade_listings'

  enum :status, { active: 0, sold: 1, expired: 2, cancelled: 3, pending: 4 }, prefix: :status
  enum :listing_type, { fixed_price: 0, auction: 1, trade_offer: 2 }, prefix: :listing_type
  enum :condition, { mint: 0, near_mint: 1, excellent: 2, good: 3, played: 4 }, prefix: :condition

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
    status.to_s
  end

  # Business operations

  def close
    # TODO: implement close
  end

  def extend(days)
    # TODO: implement extend
  end

  def cancel
    # TODO: implement cancel
  end

  def is_expired
    # TODO: implement is_expired
    nil
  end

  def finalize_auction
    # TODO: implement finalize_auction
  end

  # Lifecycle state machine
  ALLOWED_TRANSITIONS = {
    'pending' => ['active'],
    'active' => ['sold', 'expired', 'cancelled'],
  }.freeze

  def assert_transition!(to_state)
    allowed = ALLOWED_TRANSITIONS.fetch(status.to_s, [])
    unless allowed.include?(to_state.to_s)
      raise ArgumentError, "Transition #{status} -> #{to_state} not allowed"
    end
  end
end
