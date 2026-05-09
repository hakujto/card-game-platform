class DeckTagAssignment < ApplicationRecord
  self.table_name = 'deck_tag_assignments'

  belongs_to :deck, class_name: 'Deck'
  belongs_to :tag, class_name: 'DeckTag'

  def to_s
    id.to_s
  end
end
