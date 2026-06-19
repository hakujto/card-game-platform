class Card < ApplicationRecord
  self.table_name = 'cards'

  enum :card_type, { creature: 0, spell: 1, land: 2, artifact: 3, enchantment: 4, planeswalker: 5 }, prefix: :card_type
  enum :rarity, { common: 0, uncommon: 1, rare: 2, mythic_rare: 3, legendary: 4 }, prefix: :rarity
  enum :mana_colors, { white: 0, blue: 1, black: 2, red: 3, green: 4, colorless: 5 }, prefix: :mana_colors
  enum :legal_formats, { standard: 0, extended: 1, legacy: 2, vintage: 3, commander: 4, draft: 5 }, prefix: :legal_formats

  has_many :rulings, class_name: 'CardRuling', inverse_of: :card
  has_many :abilities, class_name: 'CardAbility', inverse_of: :card
  has_many :deck_cards, class_name: 'DeckCard', inverse_of: :card
  has_many :sideboard_decks, class_name: 'DeckSideboardCard', inverse_of: :card
  has_many :player_collections, class_name: 'PlayerCollection', inverse_of: :card
  has_many :crafting_recipes, class_name: 'CraftingRecipe', inverse_of: :result_card
  has_many :used_in_recipes, class_name: 'CraftingIngredient', inverse_of: :card
  has_one :shop_product, class_name: 'Product', inverse_of: :card
  has_many :trade_listings, class_name: 'TradeListing', inverse_of: :card
  has_many :price_history, class_name: 'CardPriceHistory', inverse_of: :card
  has_many :draft_picks, class_name: 'DraftPick', inverse_of: :card
  belongs_to :set, class_name: 'CardSet', inverse_of: :cards

  validates :name, presence: true, length: { maximum: 200 }

  # Domain invariants — simple rules
  validate :validate_rules

  def validate_rules
    errors.add(:mana_cost_range, 'mana_cost must be between 0 and 20') unless ((mana_cost.nil? || (mana_cost >= 0 && mana_cost <= 20)))
    errors.add(:power_level_range, 'power_level must be between 1 and 10') unless ((power_level.nil? || (power_level >= 1 && power_level <= 10)))
    errors.add(:not_banned_and_restricted, 'Card cannot be both banned and restricted at the same time') unless (!((is_banned == true && is_restricted == true)))
  end

  # Domain invariants — IMPLIES rules
  validate :validate_implies

  def validate_implies
    errors.add(:base, 'Creature card must have attack and defense') if (card_type == 'creature') && !(!attack.nil? && !defense.nil?)
    errors.add(:base, 'Planeswalker card must have loyalty') if (card_type == 'planeswalker') && loyalty.nil?
    errors.add(:base, 'Land card must have zero mana cost') if (card_type == 'land') && !(mana_cost == 0)
    errors.add(:base, 'Only Planeswalker cards can have loyalty') if (card_type != 'planeswalker') && !loyalty.nil?
    errors.add(:base, 'banned_card_not_in_legal_formats') if (is_banned == true) && !(legal_formats == "message")
  end

  def to_s
    name.to_s
  end

  # Business operations

  def ban
    # TODO: implement ban
  end

  def unban
    # TODO: implement unban
  end

  def restrict
    # TODO: implement restrict
  end

  def unrestrict
    # TODO: implement unrestrict
  end

  def calculate_value
    # TODO: implement calculate_value
    nil
  end

  def apply_rarity_bonus(multiplier)
    # TODO: implement apply_rarity_bonus
    nil
  end

  def is_legal_in_format(format)
    # TODO: implement is_legal_in_format
    nil
  end

  # Lifecycle hooks
  before_save :validate_legality
  before_destroy :validate_not_in_use

  def validate_legality
    # TODO: implement validate_legality
  end

  def validate_not_in_use
    # TODO: implement validate_not_in_use
  end
end
