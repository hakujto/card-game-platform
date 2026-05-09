class CardRuling < ApplicationRecord
  self.table_name = 'card_rulings'

  belongs_to :card, class_name: 'Card'

  validates :source, presence: true, length: { maximum: 200 }

  def to_s
    ruling_text.to_s
  end
end
