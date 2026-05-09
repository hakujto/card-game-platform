class Tradelisting < ApplicationRecord
  self.table_name = 'tradelistings'

  enum :listing_type, { fixed_price: 0, auction: 1, trade_offer: 2 }, prefix: :listing_type
  enum :condition, { mint: 0, near_mint: 1, excellent: 2, good: 3, played: 4 }, prefix: :condition
  enum :status, { active: 0, sold: 1, expired: 2, cancelled: 3, pending: 4 }, prefix: :status

  belongs_to :seller, class_name: 'Player'
  belongs_to :card, class_name: 'Card'
  belongs_to :bids, class_name: 'TradeBid', optional: true

  def to_s
    listing_type.to_s
  end
end
