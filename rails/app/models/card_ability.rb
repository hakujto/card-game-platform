class CardAbility < ApplicationRecord
  self.table_name = 'card_abilities'

  enum :ability_type, { keyword: 0, activated: 1, triggered: 2, static: 3 }, prefix: :ability_type
  enum :timing, { any: 0, sorcery: 1, instant: 2, combat: 3 }, prefix: :timing

  belongs_to :card, class_name: 'Card'

  # Domain invariants — IMPLIES rules
  validate :validate_implies

  def validate_implies
    errors.add(:base, 'Keyword ability must have a keyword name') if (ability_type == 'keyword') && keyword.nil?
  end

  def to_s
    ability_type.to_s
  end

  # Business operations

  def is_usable_at(timing)
    raise NotImplementedError, "is_usable_at not implemented"
  end

  def describe
    raise NotImplementedError, "describe not implemented"
  end
end
