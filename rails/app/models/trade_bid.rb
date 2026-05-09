class TradeBid < ApplicationRecord
  self.table_name = 'trade_bids'

  belongs_to :listing, class_name: 'Tradelisting'
  belongs_to :bidder, class_name: 'Player'

  def to_s
    amount.to_s
  end
end
