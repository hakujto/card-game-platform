class DeckSideboardCard < ApplicationRecord
  self.table_name = 'deck_sideboard_cards'

  belongs_to :deck, class_name: 'Deck'
  belongs_to :card, class_name: 'Card'

  def to_s
    quantity.to_s
  end
end
