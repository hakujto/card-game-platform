class DeckTag < ApplicationRecord
  self.table_name = 'deck_tags'

  validates :name, presence: true, length: { maximum: 50 }

  def to_s
    name.to_s
  end
end
