class Deck < ApplicationRecord
  self.table_name = 'decks'

  enum :format, { standard: 0, extended: 1, legacy: 2, vintage: 3, commander: 4, draft: 5 }, prefix: :format
  enum :archetype, { aggro: 0, control: 1, midrange: 2, combo: 3, prison: 4, tempo: 5 }, prefix: :archetype

  belongs_to :player, class_name: 'Player'
  has_many :cards, class_name: 'Card', through: :deck_cards
  has_many :sideboard_cards, class_name: 'Card', through: :deck_sideboard_cards
  has_many :tags, class_name: 'DeckTag', through: :deck_tag_assignments

  validates :name, presence: true, length: { maximum: 100 }

  def to_s
    name.to_s
  end
end
