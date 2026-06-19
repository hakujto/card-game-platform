class DeckTagAssignment < ApplicationRecord
  self.table_name = 'deck_tag_assignments'

  belongs_to :deck, class_name: 'Deck', inverse_of: :tag_assignments
  belongs_to :tag, class_name: 'DeckTag', inverse_of: :deck_assignments

  def to_s
    id.to_s
  end
end
