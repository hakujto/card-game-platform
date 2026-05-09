class TradeTransaction < ApplicationRecord
  self.table_name = 'trade_transactions'

  enum :status, { pending: 0, completed: 1, disputed: 2, refunded: 3 }

  belongs_to :listing, class_name: 'Tradelisting'
  belongs_to :buyer, class_name: 'Player'
  belongs_to :seller, class_name: 'Player'

  def to_s
    final_price.to_s
  end
end
