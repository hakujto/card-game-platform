class CardPriceHistory < ApplicationRecord
  self.table_name = 'card_price_histories'

  belongs_to :card, class_name: 'Card'

  def to_s
    price_date.to_s
  end
end
