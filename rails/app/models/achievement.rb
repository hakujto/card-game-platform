class Achievement < ApplicationRecord
  self.table_name = 'achievements'

  enum :rarity, { common: 0, uncommon: 1, rare: 2, epic: 3, legendary: 4 }

  validates :name, presence: true, length: { maximum: 200 }

  # Domain invariants — simple rules
  validate :validate_rules

  def validate_rules
    errors.add(:points_positive, 'Achievement must award at least one point') unless ((points.nil? || points > 0))
  end

  def to_s
    name.to_s
  end

  # Business operations

  def point_value(multiplier)
    raise NotImplementedError, "point_value not implemented"
  end

  def reveal
    raise NotImplementedError, "reveal not implemented"
  end
end
