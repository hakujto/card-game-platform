class Card < ApplicationRecord
  self.table_name = 'cards'

  enum :card_type, { creature: 0, spell: 1, land: 2, artifact: 3, enchantment: 4, planeswalker: 5 }, prefix: :card_type
  enum :rarity, { common: 0, uncommon: 1, rare: 2, mythic_rare: 3, legendary: 4 }, prefix: :rarity
  enum :mana_colors, { white: 0, blue: 1, black: 2, red: 3, green: 4, colorless: 5 }, prefix: :mana_colors
  enum :legal_formats, { standard: 0, extended: 1, legacy: 2, vintage: 3, commander: 4, draft: 5 }, prefix: :legal_formats

  belongs_to :set, class_name: 'CardSet'

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
    errors.add(:base, 'Only Planeswalker cards can have loyalty') if (card_type != 'planeswalker') && !loyalty.nil?
    errors.add(:base, 'banned_card_not_in_legal_formats') if (is_banned == true) && !(legal_formats == "message")
  end

  def to_s
    name.to_s
  end

  # Business operations

  def ban
    raise NotImplementedError, "ban not implemented"
  end

  def unban
    raise NotImplementedError, "unban not implemented"
  end

  def restrict
    raise NotImplementedError, "restrict not implemented"
  end

  def unrestrict
    raise NotImplementedError, "unrestrict not implemented"
  end

  def calculate_value
    raise NotImplementedError, "calculate_value not implemented"
  end

  def apply_rarity_bonus(multiplier)
    raise NotImplementedError, "apply_rarity_bonus not implemented"
  end

  def is_legal_in_format(format)
    raise NotImplementedError, "is_legal_in_format not implemented"
  end
end
