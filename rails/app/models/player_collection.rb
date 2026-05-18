class PlayerCollection < ApplicationRecord
  self.table_name = 'player_collections'

  enum :condition, { mint: 0, near_mint: 1, excellent: 2, good: 3, played: 4 }, prefix: :condition
  enum :acquired_via, { purchase: 0, trade: 1, tournament_reward: 2, pack: 3, craft: 4 }, prefix: :acquired_via

  belongs_to :player, class_name: 'Player'
  belongs_to :card, class_name: 'Card'

  # Domain invariants — simple rules
  validate :validate_rules

  def validate_rules
    errors.add(:quantity_positive, 'Collection quantity must be greater than zero') unless ((quantity.nil? || quantity > 0))
  end

  def to_s
    quantity.to_s
  end

  # Business operations

  def add(quantity)
    raise NotImplementedError, "add not implemented"
  end

  def remove(quantity)
    raise NotImplementedError, "remove not implemented"
  end

  def estimated_value
    raise NotImplementedError, "estimated_value not implemented"
  end
end
