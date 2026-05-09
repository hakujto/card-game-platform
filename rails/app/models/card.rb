class Card < ApplicationRecord
  self.table_name = 'cards'

  enum :card_type, { creature: 0, spell: 1, land: 2, artifact: 3, enchantment: 4, planeswalker: 5 }, prefix: :card_type
  enum :rarity, { common: 0, uncommon: 1, rare: 2, mythic_rare: 3, legendary: 4 }, prefix: :rarity
  enum :mana_colors, { white: 0, blue: 1, black: 2, red: 3, green: 4, colorless: 5 }, prefix: :mana_colors
  enum :legal_formats, { standard: 0, extended: 1, legacy: 2, vintage: 3, commander: 4, draft: 5 }, prefix: :legal_formats

  belongs_to :set, class_name: 'CardSet'
  belongs_to :rulings, class_name: 'CardRuling', optional: true
  belongs_to :abilities, class_name: 'CardAbility', optional: true

  validates :name, presence: true, length: { maximum: 200 }

  def to_s
    name.to_s
  end
end
